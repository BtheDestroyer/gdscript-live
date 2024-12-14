require.config({ paths: { 'vs': 'https://unpkg.com/monaco-editor@latest/min/vs' }});
window.MonacoEnvironment = { getWorkerUrl: () => proxy };

const proxy = URL.createObjectURL(new Blob([`
    self.MonacoEnvironment = {
        baseUrl: 'https://unpkg.com/monaco-editor@latest/min/'
    };
    importScripts('https://unpkg.com/monaco-editor@latest/min/vs/base/worker/workerMain.js');
`], { type: 'text/javascript' }));

var editor;
require(["vs/editor/editor.main"], function () {
    monaco.languages.register({ id: "gdscript" });
    monaco.languages.setMonarchTokensProvider("gdscript", {
        keywords: [
            "if", "elif", "else",
            "for", "while", "match",
            "break", "continue", "pass",
            "return", "class", "class_name",
            "extends", "is", "in", "as",
            "self", "super", "signal", "func",
            "static", "const", "enum", "var",
            "breakpoint", "preload", "await",
            "yield", "assert", "void",
            "PI", "TAU", "INF", "NAN"
        ],
        
        tokenizer: {
            root: [
                [/\@[a-zA-Z_]*/, "annotation"],
                [/[a-zA-Z_]\w*(?!\w*\()/, {
                    cases: {
                        "@keywords": "keyword",
                        "@default": "variable"
                    }
                }],
                [/[a-zA-Z_]\w*(?=\()/, "function-call"],
                //[/(?<=func) +[a-zA-Z_]\w*/, "function-definition"],
                [/\^"[^"\n]*"?/, "node-path"],
                [/\^[^\s"]*/, "node-path"],
                [/\$"[^"\n]*"?/, "get-node-path"],
                [/\$[^\s"]*/, "get-node-path"],
                [/&"[^"\n]*"?/, "string-name"],
                [/r?"""[^\n]*("""|\n)/, "string"],
                [/r?'''[^\n]*('''|\n)/, "string"],
                [/r?"[^"\n]*"?/, "string"],
                [/r?'[^'\n]*'?/, "string"],
                [/##[^\n]*/, "doc-comment"],
                [/#[^\n]*/, "comment"],
            ]
        }
            });
            monaco.editor.defineTheme("gdscript", {
                base: "vs-dark",
                inherit: true,
                rules: [
                    { token: "keyword", foreground: "#ff7085", fontStyle: "bold" },
                    { token: "annotation", foreground: "#ffb373", fontStyle: "bold" },
                    { token: "string-name", foreground: "#ffc2a6" },
                    { token: "node-path", foreground: "#cceea1" },
                    { token: "get-node-path", foreground: "#63c159" },
                    { token: "string", foreground: "#ffeca1" },
                    { token: "function-call", foreground: "#57b2ff" },
                    { token: "function-definition", foreground: "#66e5ff" },
                    { token: "doc-comment", foreground: "#ccccee88", fontStyle: "italic" },
                    { token: "comment", foreground: "#ccced388", fontStyle: "italic" },
                    { token: "variable", foreground: "#ffffff" },
                ],
                colors: {}
            });
            editor = monaco.editor.create(document.getElementById('code-editor'), {
                value: ("script" in query_params
                    ? atob(query_params["script"])
                    : [
                        'func main() -> void:',
                        '\tprint("Hello world!")',
                        ''
                    ].join('\n')),
                language: 'gdscript',
                theme: 'gdscript',
                automaticLayout: true
            });
            if ("script" in query_params)
            {
                runScript();
            }
        });
