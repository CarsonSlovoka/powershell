async function checkResponse(response, panic = true) {
  if (!response.ok) {
    const errMsg = await response.text()
    document.out.innerHTML += errMsg
    if (panic) {
      throw Error(`${response.statusText} (${response.status}) | ${errMsg} `)
    }
    console.error(`${response.statusText} (${response.status}) | ${errMsg} `)
    return false
  }
  return true
}
