// ==UserScript==
// @name         实验室安全考试自动答题
// @namespace    http://tampermonkey.net/
// @version      2.0
// @description  利用 (Moonshot 或者 阿里云百炼) API 提取题目进行智能选择
// @author       Gemini
// @match        *://labsafety.sysc.tsinghua.edu.cn/*
// @grant        GM_xmlhttpRequest
// @connect      api.moonshot.cn
// @connect      dashscope.aliyuncs.com
// ==/UserScript==

(function() {
    'use strict';

    let isRunning = false;
    let isPaused = false;
    let useMoonshot = true; 

    const MOONSHOT_API_KEY = ""; // 请填入你的 Moonshot API Key，格式通常为 "sk-xxxx" 开头
    const DASHSCOPE_API_KEY = "";  // 请填入你的 Dashscope API Key，格式通常为 "sk-xxxx" 开头
    const MODEL_NAME = "kimi-k2.5";

    function askAI(question, options, isMulti) {
        return new Promise((resolve) => {
            let prompt = `你是一个实验室安全考试答题专家。请根据以下题目和选项，选出正确的答案。题目是${isMulti ? '多选题' : '单选题或判断题'}。\n\n题目：${question}\n选项：\n`;
            options.forEach((opt, idx) => {
                prompt += `[${idx}] ${opt}\n`;
            });
            prompt += `\n要求：请仅仅输出正确选项对应的数字编号。如果是单选或判断，输出一个数字（如：0）；如果是多选，输出所有正确的数字编号并用逗号分隔（如：0,1,2）。绝对不要输出任何标点符号、解释、分析或其他多余的文字。`;

            const doRequest = () => {
                const currentUrl = useMoonshot 
                    ? "https://api.moonshot.cn/v1/chat/completions" // MOONSHOT接口 
                    : "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"; // dashscope接口
                
                GM_xmlhttpRequest({
                    method: "POST",
                    url: currentUrl,
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${useMoonshot ? MOONSHOT_API_KEY : DASHSCOPE_API_KEY}`
                    },
                    data: JSON.stringify({
                        model: MODEL_NAME,
                        messages: [
                            {role: "system", content: "你是一个只输出数字序号的无情答题机器，不要输出多余字符。必须严格按照要求回答。"},
                            {role: "user", content: prompt}
                        ],
                        thinking: {"type": "disabled"}

                    }),
                    onload: function(response) {
                        if (response.status === 200) {
                            try {
                                const resData = JSON.parse(response.responseText);
                                const aiReply = resData.choices[0].message.content.trim();
                                console.log(`原始回复: ${aiReply}`);

                                const match = aiReply.match(/\d+/g);
                                if (match) {
                                    let indices = [...new Set(match.map(num => parseInt(num, 10)))];
                                    indices = indices.filter(index => index >= 0 && index < options.length);
                                    if (indices.length > 0) {
                                        resolve(indices);
                                        return;
                                    }
                                }
                            } catch (e) {
                                console.error('解析 AI 响应失败:', e);
                                resolve([0]);
                            }
                        } else {
                            console.error('API 请求失败, HTTP 状态码:', response.status, response.responseText);
                            console.log('2秒后进行重试...');
                            setTimeout(doRequest, 2000);
                        }
                    },
                    onerror: function(err) {
                        console.error('API 网络错误:', err);
                        console.log('2秒后进行重试...');
                        setTimeout(doRequest, 2000);
                    }
                });
                useMoonshot = !useMoonshot; 
            };

            doRequest();
        });
    }

    async function autoAnswer() {
        if (MOONSHOT_API_KEY.includes("sk-xxxx")) {
            alert("请先在脚本代码中填入真实的 MOONSHOT_API_KEY！");
            return;
        }

        while (true) {
            if (!isRunning) {
                console.log('已手动终止答题');
                break;
            }

            if (isPaused) {
                await new Promise(r => setTimeout(r, 800));
                continue;
            }

            const questionEl = document.querySelector('.el-dialog__body h3') || document.querySelector('h3') || document.querySelector('.question-title');
            if (!questionEl) {
                console.log('未找到题目，等待页面渲染...');
                await new Promise(r => setTimeout(r, 2000));
                continue;
            }

            const question = questionEl.textContent.trim() || '';

            let currentQuestionNum = '?';
            const progressMatch = document.body.innerText.match(/第\s*(\d+)\s*题\s*\/\s*共\s*(\d+)\s*题/);
            if (progressMatch) {
                currentQuestionNum = progressMatch[1];
            } else {
                const numMatch = question.match(/^\s*(\d+)\s*[、.]/);
                if (numMatch) {
                    currentQuestionNum = numMatch[1];
                }
            }

            console.log(`\n当前正在作答第 ${currentQuestionNum} 题: ${question.substring(0, 30)}...`);

            const optionEls = document.querySelectorAll('.el-radio, .el-checkbox');
            if (optionEls.length === 0) {
                console.log('未找到选项，稍后重试...');
                await new Promise(r => setTimeout(r, 1000));
                continue;
            }

            const options = Array.from(optionEls).map(el => el.textContent.trim());
            const isMulti = document.querySelectorAll('.el-checkbox').length > 0;

            console.log(`正在请求 AI ... (题型: ${isMulti ? '多选' : '单选/判断'})`);
            const answerIndices = await askAI(question, options, isMulti);
            console.log(`AI 决定选择选项: ${answerIndices.map(i => `[${i}] ${options[i]}`).join(', ')}`);

            for (const index of answerIndices) {
                const el = optionEls[index];
                if (el) {
                    const isChecked = el.classList.contains('is-checked') || (el.querySelector('input') && el.querySelector('input').checked);
                    if (!isChecked) {
                        el.click();
                        await new Promise(r => setTimeout(r, 500));
                    }
                }
            }
            await new Promise(r => setTimeout(r, 400));

            const buttons = Array.from(document.querySelectorAll('button'));
            const nextBtn = buttons.find(btn => btn.textContent.includes('下一题') && !btn.disabled && !btn.classList.contains('is-disabled'));
            
            if (nextBtn) {
                nextBtn.click();
                await new Promise(r => setTimeout(r, 500));
            } else {
                const submitBtn = buttons.find(btn => (btn.textContent.includes('提交') || btn.textContent.includes('完成')) && !btn.disabled && !btn.classList.contains('is-disabled'));
                if (submitBtn) {
                    console.log('答题结束（已无“下一题”或是最后一道题）！');
                    break;
                }
                console.log('未找到下一题按钮，等待...');
                await new Promise(r => setTimeout(r, 2000));
            }
        }
        console.log(`本次脚本自动答题已退出。`);
    }

    function injectButton() {
        setInterval(() => {
            if (document.getElementById('ai-auto-answer-btn')) {
                return;
            }

            const startBtn = document.createElement('button');
            startBtn.id = 'ai-auto-answer-btn';
            startBtn.innerText = '开启 AI 答题';
            startBtn.style.cssText = 'position:fixed; top:80px; left:20px; z-index:999999; padding:12px 20px; background:#409EFF; color:white; border:none; border-radius:6px; cursor:pointer; box-shadow: 0 4px 10px rgba(0,0,0,0.3); font-weight:bold; font-size:14px;';

            const pauseBtn = document.createElement('button');
            pauseBtn.id = 'ai-auto-pause-btn';
            pauseBtn.innerText = '暂停答题';
            pauseBtn.style.cssText = 'position:fixed; top:80px; left:180px; z-index:999999; padding:12px 20px; background:#E6A23C; color:white; border:none; border-radius:6px; cursor:pointer; box-shadow: 0 4px 10px rgba(0,0,0,0.3); font-weight:bold; font-size:14px; display:none;';

            startBtn.onclick = () => {
                if (isRunning) {
                    isRunning = false;
                    isPaused = false;
                    startBtn.innerText = '开启 AI 答题';
                    startBtn.style.background = '#409EFF';
                    pauseBtn.style.display = 'none';
                    pauseBtn.innerText = '⏸暂停答题';
                    pauseBtn.style.background = '#E6A23C';
                } else {
                    isRunning = true;
                    isPaused = false;
                    startBtn.innerText = '停止 AI 答题';
                    startBtn.style.background = '#F56C6C';
                    pauseBtn.style.display = 'block';
                    autoAnswer().finally(() => {
                        isRunning = false;
                        isPaused = false;
                        if (document.getElementById('ai-auto-answer-btn')) {
                            const btn = document.getElementById('ai-auto-answer-btn');
                            btn.innerText = '开启 AI 答题';
                            btn.style.background = '#409EFF';
                        }
                        if (document.getElementById('ai-auto-pause-btn')) {
                            document.getElementById('ai-auto-pause-btn').style.display = 'none';
                        }
                    });
                }
            };

            pauseBtn.onclick = () => {
                if (!isRunning) return;
                
                if (isPaused) {
                    isPaused = false;
                    pauseBtn.innerText = '暂停答题';
                    pauseBtn.style.background = '#E6A23C';
                } else {
                    isPaused = true;
                    pauseBtn.innerText = '继续答题';
                    pauseBtn.style.background = '#67C23A';
                }
            };

            document.documentElement.appendChild(startBtn);
            document.documentElement.appendChild(pauseBtn);
        }, 2000);
    }

    injectButton();

})();
