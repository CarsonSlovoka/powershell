function Request-OpenAI-CreateSpeech {
    <#
    .SYNOPSIS
        將文字轉成聲音
        textToSpeech
    .DESCRIPTION
    .PARAMETER body
        response_format
          - opus: 用於忘錄串流和通信(低延遲，品質較差)
          - aac: youtube, android, iOS首選
          - flac: 無損音訊壓縮
          - wav: 為壓縮的wav，因為沒有壓縮，所以不需要經過解壓就能應用，如果您的應用程式不想要有解壓動作，也就是想快一點的開始，沒有延遲，那麼可以選擇這個
          - pcm: 與wav很像, 但包含24kHz的原始樣本(16位元 sign)，沒有標頭。不建議用這個，只會增加大小而已
    .PARAMETER output
        輸出路徑
    .EXAMPLE
        $body = @{
            model = 'tts-1' # tts-1-hd
            input = '問世間情為何物;直叫人生死相許' # 上限4096字
            voice = 'onyx' # alloy, echo, fable, onyx, nova, shimmer
            response_format = 'mp3' # 預設為mp3
            speed = 1.0 # 0.25, 4.0, 1.0
        }
        Request-OpenAI-CreateSpeech $body openai_audio_temp.mp3
        # Request-OpenAI-CreateSpeech $body > openai_audio_temp.mp3 除非直接使用curl這樣用才可以，不然從curl到pwsh，再輸出這樣的過程中間編碼會跑掉
    .LINK
        https://platform.openai.com/docs/api-reference/audio/createSpeech
    #>
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$body,
        [Parameter(Mandatory=$true)]
        [string]$output
    )

    curl -X POST 'https://api.openai.com/v1/audio/speech' `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H 'Content-Type: application/json' `
      -d ($body | ConvertTo-Json) `
      -o $output
}

function Request-OpenAI-CreateTranscription {
    <#
    .SYNOPSIS
        聲音轉文字
    .DESCRIPTION
    .PARAMETER file
    .PARAMETER lang
        輸出的語言: https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes
        放Set 1的內容: en, zh
    .PARAMETER model
        目前僅能是whisper-1
    .PARAMETER prompt
        必須與language相同，可以用一些內容來描述你的音頻，將可幫助AI可能生成的更準
    .PARAMETER response_format
        json, text, srt, verbose_json, vtt
    .PARAMETER temperature
        [0~1]
        0為固定，不會隨機更動
        如果要隨機，建議在0.2~0.8之間選

        注意: temperature調得太高，也可能得到空結果

        temperature與prompt都是獨立的，並不代表temperature為0則prompt就不重要，兩者都會影響到輸出
    .EXAMPLE
        Request-OpenAI-CreateTranscription "C:\...\my.m4a" 'zh' '新春恭喜發財的歌曲'
    .EXAMPLE
        Request-OpenAI-CreateTranscription "C:\...\my.m4a" 'zh' '新春恭喜發財的歌曲' 'json' 0.8
    .LINK
        https://platform.openai.com/docs/api-reference/audio/createTranscription
    .LINK
        # 有另外一個API為: 專門轉換英文聲音變成英文字幕
        https://platform.openai.com/docs/api-reference/audio/createTranslation
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$file,
        [Parameter(Mandatory=$true)]
        [string]$lang,

        [string]$prompt='',
        [string]$response_format='vtt',
        [int]$temperature=0,
        [string]$model='whisper-1'
    )

    curl -X POST 'https://api.openai.com/v1/audio/transcriptions' `
      -H "Authorization: Bearer $env:OPENAI_API_KEY" `
      -H 'Content-Type: multipart/form-data' `
      -F file="@$file" `
      -F model="$model" `
      -F language="$lang" `
      -F 'prompt=$prompt' `
      -F "response_format=$response_format" `
      -F temperature=$temperature
}
