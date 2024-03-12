## Runs

### [submit tool outputs to run](https://platform.openai.com/docs/api-reference/runs/submitToolOutputs)

如果你的run，有需要額外的要求輸入，例如可能你的run有用到函數，那麼這邊就可能會要求你輸入之後才可以繼續執行

有關於函數怎麼寫，官方有提供兩個例子可以參考

**股票**
```json5
{
  "name": "get_stock_price",
  "description": "Get the current stock price",
  "parameters": {
    "type": "object",
    "properties": {
      "symbol": { // 參數名稱
        "type": "string", // 參數型別
        "description": "The stock symbol" // 參數描述
      }
    },
    "required": [
      "symbol" // 必填參數為symbol
    ]
  }
}
```

**天氣查詢**
```json5
{
  "name": "get_weather",
  "description": "Determine weather in my location",
  "parameters": {
    "type": "object",
    "properties": {
      "location": { // 你的第一個參數名稱
        "type": "string",
        "description": "The city and state e.g. San Francisco, CA"
      },
      "unit": { // 第二個參數名稱
        "type": "string",
        "enum": [ // 可以用列舉，也就是只能輸入這些清單內的內容
          "c", // 攝氏 // 擺在前面第一個，會是預設值
          "f" // 華視
        ]
      }
    },
    "required": [ // 看你有那些必要的參數就填入
      "location" // 以這個例子而言，他的必填參數為location
    ]
  }
}
```

在詢問AI的時候，不需要真的使用函數來呼叫，透過自然的對話，AI會自動判斷是否要去呼叫某一個參數，以及如果要用，那麼他相關的參數可能是放什麼數值
AI會自己決定，但決定完成之後還會讓使用者同意是否認為AI放的參數都是對的，都是對的可以提交，接下來AI就會自動執行
