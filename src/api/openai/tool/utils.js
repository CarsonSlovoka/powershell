async function checkResponse(response, outputElem, panic = true) {
  if (!response.ok) {
    const errMsg = await response.text()
    outputElem.innerHTML += errMsg
    if (panic) {
      throw Error(`${response.statusText} (${response.status}) | ${errMsg} `)
    }
    console.error(`${response.statusText} (${response.status}) | ${errMsg} `)
    return false
  }
  return true
}
