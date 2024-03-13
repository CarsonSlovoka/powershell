async function DeleteThread(threadID) {
  const endPoint = `https://api.openai.com/v1/threads/${threadID}`
  console.log(endPoint)
  const response = await fetch(endPoint, {
    method: "DELETE",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${document.apiKey}`,
      "OpenAI-Beta": "assistants=v1",
    }
  })
  await checkResponse(response, false)
  document.out.innerHTML += JSON.stringify(await response.json(), null, "  ")
}

async function GetThreads(threadID, limit = 10, order = "asc") {
  const endPoint = `https://api.openai.com/v1/threads/${threadID}/messages?limit=${limit}&order=${order}`
  console.log(endPoint)
  const response = await fetch(endPoint, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${document.apiKey}`,
      'OpenAI-Beta': 'assistants=v1'
    }
  })
  if (!await checkResponse(response, false)) {
    return
  }
  const obj = await response.json()
  if (obj.data.length < 2) {
    document.out.innerHTML += `此thread: ${threadID}資料很少: ${obj.data.length}筆，建議使用deleteThread刪除<br>`
    return
  }
  console.log(obj)
  document.out.innerHTML += JSON.stringify(obj, null, "  ")

  const assistantID = obj.data[1].assistant_id // 第二筆通常就會有: assistant_id，因為通常第一筆是user的提問，第二筆就會換成機器人問，當然也有可能是user問了兩次之後才執行action run，但這種情況就不討論
  if (assistantID !== null) {
    window.open(`https://platform.openai.com/playground?assistant=${assistantID}&mode=assistant&thread=${threadID}`, "_blank") // 一次只能彈一個，如果連續彈好幾個，可能會被瀏覽器封鎖，要允許才可以: chrome://settings/content/popups
    // return playURL
  }
}

async function ListAllThreads(sessionKey, limit = 10) {
  if (sessionKey === "") {
    alert("sessionKey為空")
    return
  }
  const endPoint = `https://api.openai.com/v1/threads?&limit=${limit}`
  console.log(endPoint)
  const progress = document.querySelector("progress")
  progress.value = 0
  const response = await fetch(endPoint, {
    headers: {
      "Authorization": `Bearer ${sessionKey}`,
      'OpenAI-Beta': 'assistants=v1'
    }
  })
  if (!await checkResponse(response, false)) {
    progress.value = 100
    return
  }
  const obj = await response.json()
  const step = Math.trunc(100 / obj.data.length) // 進度不能有小數
  for (const e of obj.data) {
    // created_at: 1710226246
    // new Date(1504095567183)
    // e.created_at = new Date(e.created_at*1000).toLocaleDateString("zh-TW") // convert unix_timestamp to local time // 2024/3/11
    e.created_at = new Date(e.created_at * 1000).toLocaleString(undefined, {
      year: '2-digit',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      hour12: false,
      minute: '2-digit',
      second: '2-digit'
    })
    const threadID = e.id
    await GetThreads(threadID, 2, "asc") // 取前2筆即可 // 他會自己再去開啟playground
    progress.value += step
  }
  progress.value = 100

  console.log(obj)
  document.out.innerHTML += JSON.stringify(obj, null, "  ")
}
