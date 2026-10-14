# gem corpus results

Tool: `tools/run_gem_corpus.py`. Oracle: CRuby + raylib-bindings; Spinel: `spinel` with `spin flags`.

## raylib-bindings examples (loader line replaced, `spinel -c`)

| verdict | count |
| --- | --- |
| analyzed | 10 |
| bare-call | 2 |
| refusal | 58 |

70 examples total.

First bare-call blocker (same shape for all 2):

```
/tmp/tmpdc8_36qx/core_loading_thread.rb:1352: unsupported call: node 43304 (CallNode `TraceLog`) recv=-/ty-1 argc=2 arg0ty3
```
