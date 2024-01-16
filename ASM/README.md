# Introduction

```c
asm [volatile](
    'AssemblerTemplate'
    : 'OutputOperands'
    [ : 'InputOperands']
    [ : 'Clobbers' ]
)

asm [volatile] goto (
    'AssemblerTemplate'
    : 
    : 'InputOperands'
    : 'Clobbers'
    : 'GotoLabels'
)
```

