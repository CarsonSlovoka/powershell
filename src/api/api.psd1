@{
ModuleVersion = '1.0'
# Microsoft.PowerShell.Utility\New-Guid
GUID = '63154f9a-e197-4121-9747-b45969802244'
Description = ''
PowerShellVersion = '7.0'
NestedModules = @(
    'openai/help.psm1',

    # Assistants
    'openai/msg.psm1',
    'openai/thread.psm1',
    'openai/runs.psm1'

    'openai/audio.psm1'
)
FunctionsToExport = @(
    # openai/thread,message
    'Request-OpenAI-Help',
    'Request-OpenAI-OpenPlayground',

    'Request-OpenAI-ListThread',
    'Request-OpenAI-GetThreads',
    'Request-OpenAI-DeleteThread',

    'Request-OpenAI-CreateMessage',
    'Request-OpenAI-GetThreadMsg',
    'Request-OpenAI-ListThreadMsg',
    'Request-OpenAI-ModifyMessage',

    'Request-OpenAI-CreateRun',
    'Request-OpenAI-ListRuns',
    'Request-OpenAI-GetRun',
    'Request-OpenAI-ListRunSteps',
    'Request-OpenAI-ModifyRun',
    'Request-OpenAI-CancelRun',
    'Request-OpenAI-SubmitToRun',
    'Request-OpenAI-SubmitToRunEx'

    # openai/audio
    'Request-OpenAI-CreateSpeech',
    'Request-OpenAI-CreateTranscription'
)
AliasesToExport = @(
)
VariablesToExport = '*'
CmdletsToExport = @()
PrivateData = @{
    PSData = @{}
}
}
