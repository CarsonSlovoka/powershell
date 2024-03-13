document.forms["config"].onsubmit = e => {
  e.preventDefault()
  e.target.querySelector(`input[name=sessionKey]`).onchange()
  return false
}

document.apiKey = sessionStorage.getItem("apiKey")
if (document.apiKey !== "") {
  document.querySelector("#apiKey").value = document.apiKey
}

document.out = document.querySelector("#output")
document.forms['assistant'].onsubmit = async e => {
  const f = e.target
  e.preventDefault()
  document.out.innerHTML = ""
  switch (f.action.value) {
    case "GetThreads":
      await GetThreads(f.threadID.value, f.limit.value, f.order.value)
      break
    case "DeleteThread":
      await DeleteThread(f.threadID.value)
      break
  }
  return false
}

document.forms['CreateSpeech'].onsubmit = async e => {
  const f = e.target
  e.preventDefault()
  const outElem = f.querySelector("pre.output")
  outElem.innerHTML = ''
  await CreateSpeech(outElem,
    f.model.value,
    f.input.value,
    f.voice.value,
    f.response_format.value,
    f.speed.value
  )
  return false
}

document.forms['SpeechToText'].onsubmit = async e => {
  const f = e.target
  e.preventDefault()
  const outElem = f.querySelector("pre.output")
  outElem.innerHTML = ''
  await SpeechToText(outElem, f.file.files[0],
    f.model.value,
    f.lang.value,
    f.prompt.value,
    f.response_format.value,
    f.temperature.value,
  )
  return false
}
