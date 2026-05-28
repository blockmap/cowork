#!/bin/bash
# verify_fix.sh - 验证模型名称转换修复

cd /Users/block/code/cowork

cat > /tmp/test_fix.rs << 'EOF'
use std::borrow::Cow;

const DEFAULT_OPENAI_BASE_URL: &str = "https://api.openai.com/v1";

fn wire_model_for_base_url<'a>(
    model: &'a str,
    provider_name: &str,
    base_url: &str,
) -> Cow<'a, str> {
    let Some(pos) = model.find('/') else {
        return Cow::Borrowed(model);
    };
    let prefix = &model[..pos];
    let lowered_prefix = prefix.to_ascii_lowercase();

    if lowered_prefix == "openai" {
        let trimmed_base_url = base_url.trim_end_matches('/');
        let default_openai = DEFAULT_OPENAI_BASE_URL.trim_end_matches('/');
        if provider_name == "OpenAI" && trimmed_base_url != default_openai {
            if !model.contains("gemini") && !model.contains("gemma") {
                return Cow::Borrowed(&model[pos + 1..]);  // 修复后的代码
            }
        }
        return Cow::Borrowed(&model[pos + 1..]);
    }

    Cow::Borrowed(model)
}

fn main() {
    println!("=== 修复验证 ===");
    println!();
    
    let test_cases = [
        ("openai/qwen3.5:0.8b", "OpenAI", "http://192.168.68.213:19000/v1"),
        ("openai/llama3.2", "OpenAI", "http://localhost:11434/v1"),
        ("openai/gpt-4o", "OpenAI", "https://api.openai.com/v1"),
    ];

    for (model, provider, base_url) in test_cases {
        let result = wire_model_for_base_url(model, provider, base_url);
        println!("输入: {} @ {}", model, base_url);
        println!("输出: {}", result);
        println!();
    }
}
EOF

rustc /tmp/test_fix.rs -o /tmp/test_fix && /tmp/test_fix