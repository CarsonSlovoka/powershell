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
