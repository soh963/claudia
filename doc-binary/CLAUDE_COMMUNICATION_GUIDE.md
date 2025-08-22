# Claude Communication Guide
완전한 개발 가이드: Frontend (React/TS) ↔ Tauri ↔ Rust ↔ Claude API

## 목차
1. [개요](#개요)
2. [아키텍처 설계](#아키텍처-설계)
3. [환경 설정](#환경-설정)
4. [Frontend 개발 (React/TypeScript)](#frontend-개발-reacttypescript)
5. [Tauri 설정 및 통합](#tauri-설정-및-통합)
6. [Rust Backend 개발](#rust-backend-개발)
7. [Claude API 통합](#claude-api-통합)
8. [스트리밍 구현](#스트리밍-구현)
9. [오류 처리](#오류-처리)
10. [보안 구현](#보안-구현)
11. [성능 최적화](#성능-최적화)
12. [테스트 및 배포](#테스트-및-배포)

## 개요

이 가이드는 Claude API를 활용한 완전한 데스크톱 애플리케이션 개발을 다룹니다. 초보자도 따라할 수 있도록 모든 단계를 상세히 설명합니다.

### 기술 스택
- **Frontend**: React 18 + TypeScript + Vite
- **Desktop**: Tauri 2.0
- **Backend**: Rust (tokio, serde, reqwest)
- **API**: Claude 3.5 Sonnet
- **상태관리**: Zustand
- **스타일링**: Tailwind CSS

## 아키텍처 설계

### 전체 아키텍처
```
┌─────────────────────────────────────────┐
│                Frontend                  │
│  React + TypeScript + Tailwind CSS     │
│  ┌─────────────────┐ ┌─────────────────┐│
│  │   UI Components │ │  State Manager  ││
│  │                 │ │   (Zustand)     ││
│  └─────────────────┘ └─────────────────┘│
└─────────────────┬───────────────────────┘
                  │ Tauri Commands
┌─────────────────▼───────────────────────┐
│                Tauri                     │
│           Rust Backend                   │
│  ┌─────────────────┐ ┌─────────────────┐│
│  │  Command Handler│ │   HTTP Client   ││
│  │                 │ │                 ││
│  └─────────────────┘ └─────────────────┘│
└─────────────────┬───────────────────────┘
                  │ HTTP Requests
┌─────────────────▼───────────────────────┐
│              Claude API                  │
│         Anthropic Service               │
└─────────────────────────────────────────┘
```

### 데이터 플로우
1. **사용자 입력** → React 컴포넌트
2. **상태 업데이트** → Zustand Store
3. **Tauri 명령 호출** → Rust Backend
4. **API 요청** → Claude API
5. **스트리밍 응답** → 실시간 UI 업데이트

## 환경 설정

### 1. 시스템 요구사항
```bash
# Node.js 18+
node --version

# Rust (최신 안정 버전)
rustc --version

# Tauri CLI
npm install -g @tauri-apps/cli
```

### 2. 프로젝트 초기화
```bash
# 새 Tauri 프로젝트 생성
npm create tauri-app@latest claude-chat
cd claude-chat

# 패키지 설치
npm install

# Tauri 개발 환경 시작
npm run tauri dev
```

### 3. 핵심 의존성 설치

#### Frontend 패키지
```bash
npm install \
  zustand \
  @types/react @types/react-dom \
  tailwindcss autoprefixer postcss \
  lucide-react \
  react-markdown \
  @tauri-apps/api
```

#### Rust 의존성 (Cargo.toml)
```toml
[dependencies]
tauri = { version = "2.0", features = ["shell-open"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.0", features = ["full"] }
reqwest = { version = "0.11", features = ["json", "stream"] }
uuid = { version = "1.0", features = ["v4"] }
chrono = { version = "0.4", features = ["serde"] }
anyhow = "1.0"
thiserror = "1.0"
```

## Frontend 개발 (React/TypeScript)

### 1. 타입 정의
```typescript
// src/types/index.ts
export interface Message {
  id: string;
  content: string;
  role: 'user' | 'assistant';
  timestamp: Date;
  status: 'sending' | 'completed' | 'error';
}

export interface ChatState {
  messages: Message[];
  isLoading: boolean;
  error: string | null;
  addMessage: (message: Omit<Message, 'id' | 'timestamp'>) => void;
  updateMessage: (id: string, updates: Partial<Message>) => void;
  clearMessages: () => void;
  sendMessage: (content: string) => Promise<void>;
}

export interface ClaudeResponse {
  content: string;
  usage?: {
    input_tokens: number;
    output_tokens: number;
  };
}

export interface StreamChunk {
  type: 'content_block_delta' | 'message_delta' | 'error';
  delta?: {
    text: string;
  };
  error?: string;
}
```

### 2. Zustand 상태 관리
```typescript
// src/store/chatStore.ts
import { create } from 'zustand';
import { invoke } from '@tauri-apps/api/core';
import { Message, ChatState, ClaudeResponse } from '../types';
import { v4 as uuidv4 } from 'uuid';

export const useChatStore = create<ChatState>((set, get) => ({
  messages: [],
  isLoading: false,
  error: null,

  addMessage: (message) => {
    const newMessage: Message = {
      ...message,
      id: uuidv4(),
      timestamp: new Date(),
    };
    set((state) => ({
      messages: [...state.messages, newMessage],
    }));
  },

  updateMessage: (id, updates) => {
    set((state) => ({
      messages: state.messages.map((msg) =>
        msg.id === id ? { ...msg, ...updates } : msg
      ),
    }));
  },

  clearMessages: () => {
    set({ messages: [], error: null });
  },

  sendMessage: async (content: string) => {
    const { addMessage, updateMessage } = get();
    
    // 사용자 메시지 추가
    addMessage({
      content,
      role: 'user',
      status: 'completed',
    });

    // AI 응답 메시지 생성
    const assistantId = uuidv4();
    addMessage({
      id: assistantId,
      content: '',
      role: 'assistant',
      status: 'sending',
    });

    set({ isLoading: true, error: null });

    try {
      // Tauri 명령 호출 (스트리밍)
      await invoke('send_message_stream', {
        message: content,
        messageId: assistantId,
      });
    } catch (error) {
      console.error('메시지 전송 실패:', error);
      updateMessage(assistantId, {
        content: '오류가 발생했습니다.',
        status: 'error',
      });
      set({ error: error as string });
    } finally {
      set({ isLoading: false });
    }
  },
}));

// 스트리밍 업데이트 핸들러
export const handleStreamUpdate = (messageId: string, chunk: string) => {
  const { updateMessage } = useChatStore.getState();
  updateMessage(messageId, {
    content: chunk,
    status: 'sending',
  });
};

export const handleStreamComplete = (messageId: string) => {
  const { updateMessage } = useChatStore.getState();
  updateMessage(messageId, {
    status: 'completed',
  });
};
```

### 3. 핵심 컴포넌트

#### ChatMessage 컴포넌트
```typescript
// src/components/ChatMessage.tsx
import React from 'react';
import ReactMarkdown from 'react-markdown';
import { User, Bot, Clock, AlertCircle } from 'lucide-react';
import { Message } from '../types';

interface ChatMessageProps {
  message: Message;
}

export const ChatMessage: React.FC<ChatMessageProps> = ({ message }) => {
  const isUser = message.role === 'user';
  
  return (
    <div className={`flex gap-3 p-4 ${isUser ? 'bg-blue-50' : 'bg-gray-50'}`}>
      <div className="flex-shrink-0">
        {isUser ? (
          <User className="w-6 h-6 text-blue-600" />
        ) : (
          <Bot className="w-6 h-6 text-green-600" />
        )}
      </div>
      
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <span className="font-medium text-sm">
            {isUser ? '사용자' : 'Claude'}
          </span>
          <span className="text-xs text-gray-500">
            {message.timestamp.toLocaleTimeString()}
          </span>
          {message.status === 'sending' && (
            <Clock className="w-3 h-3 text-yellow-500 animate-spin" />
          )}
          {message.status === 'error' && (
            <AlertCircle className="w-3 h-3 text-red-500" />
          )}
        </div>
        
        <div className="prose prose-sm max-w-none">
          {isUser ? (
            <p className="whitespace-pre-wrap">{message.content}</p>
          ) : (
            <ReactMarkdown>{message.content}</ReactMarkdown>
          )}
        </div>
      </div>
    </div>
  );
};
```

#### ChatInput 컴포넌트
```typescript
// src/components/ChatInput.tsx
import React, { useState, KeyboardEvent } from 'react';
import { Send, Loader2 } from 'lucide-react';
import { useChatStore } from '../store/chatStore';

export const ChatInput: React.FC = () => {
  const [input, setInput] = useState('');
  const { sendMessage, isLoading } = useChatStore();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const message = input.trim();
    setInput('');
    await sendMessage(message);
  };

  const handleKeyPress = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="p-4 border-t bg-white">
      <div className="flex gap-2">
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={handleKeyPress}
          placeholder="Claude에게 메시지를 보내세요..."
          className="flex-1 resize-none border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
          rows={3}
          disabled={isLoading}
        />
        <button
          type="submit"
          disabled={!input.trim() || isLoading}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : (
            <Send className="w-4 h-4" />
          )}
        </button>
      </div>
    </form>
  );
};
```

#### 메인 Chat 컴포넌트
```typescript
// src/components/Chat.tsx
import React, { useEffect, useRef } from 'react';
import { useChatStore } from '../store/chatStore';
import { ChatMessage } from './ChatMessage';
import { ChatInput } from './ChatInput';
import { Trash2 } from 'lucide-react';

export const Chat: React.FC = () => {
  const { messages, clearMessages } = useChatStore();
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  return (
    <div className="flex flex-col h-screen bg-white">
      {/* 헤더 */}
      <div className="flex items-center justify-between p-4 border-b bg-gray-50">
        <h1 className="text-xl font-bold text-gray-800">Claude Chat</h1>
        <button
          onClick={clearMessages}
          className="p-2 text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-lg"
          title="대화 기록 삭제"
        >
          <Trash2 className="w-4 h-4" />
        </button>
      </div>

      {/* 메시지 영역 */}
      <div className="flex-1 overflow-y-auto">
        {messages.length === 0 ? (
          <div className="flex items-center justify-center h-full text-gray-500">
            <p>Claude와 대화를 시작해보세요!</p>
          </div>
        ) : (
          messages.map((message) => (
            <ChatMessage key={message.id} message={message} />
          ))
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* 입력 영역 */}
      <ChatInput />
    </div>
  );
};
```

## Tauri 설정 및 통합

### 1. Tauri 설정 (tauri.conf.json)
```json
{
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devPath": "http://localhost:1420",
    "distDir": "../dist"
  },
  "package": {
    "productName": "Claude Chat",
    "version": "0.1.0"
  },
  "tauri": {
    "allowlist": {
      "all": false,
      "shell": {
        "all": false,
        "open": true
      },
      "window": {
        "all": false,
        "close": true,
        "hide": true,
        "show": true,
        "maximize": true,
        "minimize": true,
        "unmaximize": true,
        "unminimize": true,
        "startDragging": true
      }
    },
    "bundle": {
      "active": true,
      "targets": "all",
      "identifier": "com.claude.chat",
      "icon": [
        "icons/32x32.png",
        "icons/128x128.png",
        "icons/128x128@2x.png",
        "icons/icon.icns",
        "icons/icon.ico"
      ]
    },
    "security": {
      "csp": null
    },
    "windows": [
      {
        "fullscreen": false,
        "resizable": true,
        "title": "Claude Chat",
        "width": 1000,
        "height": 700,
        "minWidth": 400,
        "minHeight": 300
      }
    ]
  }
}
```

### 2. Tauri 이벤트 시스템 설정
```typescript
// src/utils/tauriEvents.ts
import { listen } from '@tauri-apps/api/event';
import { handleStreamUpdate, handleStreamComplete } from '../store/chatStore';

export interface StreamEvent {
  message_id: string;
  content: string;
  is_complete: boolean;
}

export const setupTauriEvents = async () => {
  // 스트리밍 업데이트 이벤트 리스너
  await listen<StreamEvent>('stream-update', (event) => {
    const { message_id, content, is_complete } = event.payload;
    
    if (is_complete) {
      handleStreamComplete(message_id);
    } else {
      handleStreamUpdate(message_id, content);
    }
  });

  // 오류 이벤트 리스너
  await listen<{ message_id: string; error: string }>('stream-error', (event) => {
    const { message_id, error } = event.payload;
    const { updateMessage } = useChatStore.getState();
    updateMessage(message_id, {
      content: `오류: ${error}`,
      status: 'error',
    });
  });
};
```

## Rust Backend 개발

### 1. 메인 모듈 구조
```rust
// src-tauri/src/main.rs
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod claude;
mod error;
mod state;

use claude::ClaudeClient;
use error::{Result, AppError};
use state::AppState;
use tauri::{Manager, State};
use std::sync::Arc;

#[derive(Clone, serde::Serialize)]
struct StreamEvent {
    message_id: String,
    content: String,
    is_complete: bool,
}

#[derive(Clone, serde::Serialize)]
struct StreamErrorEvent {
    message_id: String,
    error: String,
}

#[tauri::command]
async fn send_message_stream(
    message: String,
    message_id: String,
    state: State<'_, AppState>,
    app: tauri::AppHandle,
) -> Result<()> {
    let client = &state.claude_client;
    
    tokio::spawn(async move {
        match client.send_message_stream(&message, &message_id, &app).await {
            Ok(_) => {
                let _ = app.emit_all("stream-update", StreamEvent {
                    message_id: message_id.clone(),
                    content: String::new(),
                    is_complete: true,
                });
            }
            Err(e) => {
                let _ = app.emit_all("stream-error", StreamErrorEvent {
                    message_id,
                    error: e.to_string(),
                });
            }
        }
    });

    Ok(())
}

fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let claude_client = ClaudeClient::new()?;
            app.manage(AppState {
                claude_client: Arc::new(claude_client),
            });
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![send_message_stream])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 2. Claude API 클라이언트
```rust
// src-tauri/src/claude.rs
use reqwest::Client;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::time::Duration;
use tauri::AppHandle;
use crate::error::{Result, AppError};

#[derive(Debug, Serialize)]
struct ClaudeMessage {
    role: String,
    content: String,
}

#[derive(Debug, Serialize)]
struct ClaudeRequest {
    model: String,
    max_tokens: i32,
    messages: Vec<ClaudeMessage>,
    stream: bool,
}

#[derive(Debug, Deserialize)]
struct ClaudeStreamResponse {
    #[serde(rename = "type")]
    event_type: String,
    delta: Option<Delta>,
}

#[derive(Debug, Deserialize)]
struct Delta {
    #[serde(rename = "type")]
    delta_type: Option<String>,
    text: Option<String>,
}

pub struct ClaudeClient {
    client: Client,
    api_key: String,
}

impl ClaudeClient {
    pub fn new() -> Result<Self> {
        let api_key = std::env::var("CLAUDE_API_KEY")
            .map_err(|_| AppError::ConfigError("CLAUDE_API_KEY not found".to_string()))?;

        let client = Client::builder()
            .timeout(Duration::from_secs(60))
            .build()
            .map_err(|e| AppError::NetworkError(e.to_string()))?;

        Ok(Self { client, api_key })
    }

    pub async fn send_message_stream(
        &self,
        message: &str,
        message_id: &str,
        app: &AppHandle,
    ) -> Result<()> {
        let request = ClaudeRequest {
            model: "claude-3-5-sonnet-20241022".to_string(),
            max_tokens: 4096,
            messages: vec![ClaudeMessage {
                role: "user".to_string(),
                content: message.to_string(),
            }],
            stream: true,
        };

        let response = self
            .client
            .post("https://api.anthropic.com/v1/messages")
            .header("Authorization", format!("Bearer {}", self.api_key))
            .header("Content-Type", "application/json")
            .header("anthropic-version", "2023-06-01")
            .json(&request)
            .send()
            .await
            .map_err(|e| AppError::NetworkError(e.to_string()))?;

        if !response.status().is_success() {
            let status = response.status();
            let text = response.text().await.unwrap_or_default();
            return Err(AppError::ApiError(format!("HTTP {}: {}", status, text)));
        }

        let mut stream = response.bytes_stream();
        let mut accumulated_content = String::new();

        use futures_util::StreamExt;
        while let Some(chunk) = stream.next().await {
            let chunk = chunk.map_err(|e| AppError::NetworkError(e.to_string()))?;
            let chunk_str = String::from_utf8_lossy(&chunk);

            // SSE 파싱
            for line in chunk_str.lines() {
                if line.starts_with("data: ") {
                    let data = &line[6..];
                    if data == "[DONE]" {
                        break;
                    }

                    if let Ok(parsed) = serde_json::from_str::<ClaudeStreamResponse>(data) {
                        if let Some(delta) = parsed.delta {
                            if let Some(text) = delta.text {
                                accumulated_content.push_str(&text);
                                
                                let _ = app.emit_all("stream-update", crate::StreamEvent {
                                    message_id: message_id.to_string(),
                                    content: accumulated_content.clone(),
                                    is_complete: false,
                                });
                            }
                        }
                    }
                }
            }
        }

        Ok(())
    }
}
```

### 3. 에러 처리
```rust
// src-tauri/src/error.rs
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Network error: {0}")]
    NetworkError(String),
    
    #[error("API error: {0}")]
    ApiError(String),
    
    #[error("Configuration error: {0}")]
    ConfigError(String),
    
    #[error("Serialization error: {0}")]
    SerializationError(String),
}

impl serde::Serialize for AppError {
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: serde::ser::Serializer,
    {
        serializer.serialize_str(self.to_string().as_ref())
    }
}

pub type Result<T> = std::result::Result<T, AppError>;
```

### 4. 앱 상태 관리
```rust
// src-tauri/src/state.rs
use crate::claude::ClaudeClient;
use std::sync::Arc;

pub struct AppState {
    pub claude_client: Arc<ClaudeClient>,
}
```

## Claude API 통합

### 1. 환경 변수 설정
```bash
# .env
CLAUDE_API_KEY=your_api_key_here
```

### 2. API 래퍼 함수
```typescript
// src/api/claude.ts
import { invoke } from '@tauri-apps/api/core';

export interface ClaudeConfig {
  model: string;
  maxTokens: number;
  temperature?: number;
}

export const sendMessage = async (
  message: string,
  messageId: string,
  config?: ClaudeConfig
) => {
  try {
    await invoke('send_message_stream', {
      message,
      messageId,
      config: config || {
        model: 'claude-3-5-sonnet-20241022',
        maxTokens: 4096,
        temperature: 0.7,
      },
    });
  } catch (error) {
    console.error('API 호출 실패:', error);
    throw error;
  }
};
```

## 스트리밍 구현

### 1. Server-Sent Events 파싱
```rust
// Claude API 스트리밍 응답 처리
impl ClaudeClient {
    async fn parse_sse_stream(&self, response: Response) -> Result<Vec<String>> {
        let mut stream = response.bytes_stream();
        let mut chunks = Vec::new();
        
        while let Some(chunk) = stream.next().await {
            let chunk = chunk.map_err(|e| AppError::NetworkError(e.to_string()))?;
            let chunk_str = String::from_utf8_lossy(&chunk);
            
            for line in chunk_str.lines() {
                if line.starts_with("data: ") {
                    let data = &line[6..];
                    if data != "[DONE]" {
                        chunks.push(data.to_string());
                    }
                }
            }
        }
        
        Ok(chunks)
    }
}
```

### 2. 실시간 UI 업데이트
```typescript
// 타이핑 효과 구현
export const useTypingEffect = (text: string, speed: number = 50) => {
  const [displayText, setDisplayText] = useState('');
  const [isTyping, setIsTyping] = useState(false);

  useEffect(() => {
    if (!text) return;
    
    setIsTyping(true);
    setDisplayText('');
    
    let index = 0;
    const timer = setInterval(() => {
      setDisplayText(text.slice(0, index + 1));
      index++;
      
      if (index === text.length) {
        clearInterval(timer);
        setIsTyping(false);
      }
    }, speed);

    return () => clearInterval(timer);
  }, [text, speed]);

  return { displayText, isTyping };
};
```

## 오류 처리

### 1. 네트워크 오류 처리
```rust
impl ClaudeClient {
    pub async fn send_with_retry(
        &self,
        message: &str,
        max_retries: u32,
    ) -> Result<String> {
        let mut last_error = None;
        
        for attempt in 0..=max_retries {
            match self.send_message(message).await {
                Ok(response) => return Ok(response),
                Err(e) => {
                    last_error = Some(e);
                    if attempt < max_retries {
                        let delay = Duration::from_secs(2_u64.pow(attempt));
                        tokio::time::sleep(delay).await;
                    }
                }
            }
        }
        
        Err(last_error.unwrap())
    }
}
```

### 2. 사용자 친화적 오류 메시지
```typescript
// src/utils/errorHandler.ts
export const getErrorMessage = (error: any): string => {
  if (typeof error === 'string') {
    return error;
  }
  
  if (error.message) {
    if (error.message.includes('network')) {
      return '네트워크 연결을 확인해주세요.';
    }
    if (error.message.includes('api_key')) {
      return 'API 키가 올바르지 않습니다.';
    }
    if (error.message.includes('rate_limit')) {
      return '요청 한도에 도달했습니다. 잠시 후 다시 시도해주세요.';
    }
    return error.message;
  }
  
  return '알 수 없는 오류가 발생했습니다.';
};
```

## 보안 구현

### 1. API 키 보안
```rust
// 환경 변수에서 안전하게 API 키 로드
impl ClaudeClient {
    pub fn new() -> Result<Self> {
        let api_key = std::env::var("CLAUDE_API_KEY")
            .or_else(|_| {
                // 키체인이나 보안 저장소에서 로드
                load_from_secure_storage("claude_api_key")
            })
            .map_err(|_| AppError::ConfigError("API key not found".to_string()))?;
            
        // API 키 유효성 검증
        if !api_key.starts_with("sk-") {
            return Err(AppError::ConfigError("Invalid API key format".to_string()));
        }
        
        Ok(Self { api_key, ..Default::default() })
    }
}
```

### 2. 입력 검증 및 새니타이징
```typescript
// src/utils/validation.ts
export const validateInput = (input: string): { isValid: boolean; error?: string } => {
  if (!input.trim()) {
    return { isValid: false, error: '메시지를 입력해주세요.' };
  }
  
  if (input.length > 10000) {
    return { isValid: false, error: '메시지가 너무 깁니다. (최대 10,000자)' };
  }
  
  // 악성 코드 패턴 검사
  const maliciousPatterns = [
    /<script/i,
    /javascript:/i,
    /on\w+\s*=/i,
  ];
  
  for (const pattern of maliciousPatterns) {
    if (pattern.test(input)) {
      return { isValid: false, error: '허용되지 않는 내용이 포함되어 있습니다.' };
    }
  }
  
  return { isValid: true };
};

export const sanitizeInput = (input: string): string => {
  return input
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+\s*=/gi, '');
};
```

## 성능 최적화

### 1. 메모리 관리
```rust
// 메시지 히스토리 관리
pub struct MessageHistory {
    messages: VecDeque<Message>,
    max_size: usize,
}

impl MessageHistory {
    pub fn add_message(&mut self, message: Message) {
        if self.messages.len() >= self.max_size {
            self.messages.pop_front();
        }
        self.messages.push_back(message);
    }
    
    pub fn get_context(&self, max_tokens: usize) -> Vec<Message> {
        let mut total_tokens = 0;
        let mut context = Vec::new();
        
        for message in self.messages.iter().rev() {
            let estimated_tokens = message.content.len() / 4; // 대략적 추정
            if total_tokens + estimated_tokens > max_tokens {
                break;
            }
            
            context.insert(0, message.clone());
            total_tokens += estimated_tokens;
        }
        
        context
    }
}
```

### 2. 가상 스크롤링
```typescript
// src/components/VirtualizedMessageList.tsx
import { FixedSizeList as List } from 'react-window';

interface VirtualizedMessageListProps {
  messages: Message[];
  height: number;
}

export const VirtualizedMessageList: React.FC<VirtualizedMessageListProps> = ({
  messages,
  height,
}) => {
  const itemHeight = 100; // 예상 메시지 높이

  const MessageItem = ({ index, style }: { index: number; style: any }) => (
    <div style={style}>
      <ChatMessage message={messages[index]} />
    </div>
  );

  return (
    <List
      height={height}
      itemCount={messages.length}
      itemSize={itemHeight}
      width="100%"
    >
      {MessageItem}
    </List>
  );
};
```

### 3. 이미지 최적화
```typescript
// src/components/OptimizedImage.tsx
export const OptimizedImage: React.FC<{ src: string; alt: string }> = ({
  src,
  alt,
}) => {
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState(false);

  return (
    <div className="relative">
      {!loaded && !error && (
        <div className="animate-pulse bg-gray-200 w-full h-32" />
      )}
      <img
        src={src}
        alt={alt}
        onLoad={() => setLoaded(true)}
        onError={() => setError(true)}
        className={`transition-opacity duration-300 ${
          loaded ? 'opacity-100' : 'opacity-0'
        }`}
        loading="lazy"
      />
      {error && (
        <div className="text-gray-500 text-center p-4">
          이미지를 불러올 수 없습니다.
        </div>
      )}
    </div>
  );
};
```

## 테스트 및 배포

### 1. 단위 테스트
```rust
// src-tauri/src/claude.rs
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_claude_client_creation() {
        std::env::set_var("CLAUDE_API_KEY", "sk-test-key");
        let client = ClaudeClient::new();
        assert!(client.is_ok());
    }
    
    #[test]
    fn test_message_validation() {
        let valid_message = "Hello, Claude!";
        assert!(validate_message(valid_message).is_ok());
        
        let empty_message = "";
        assert!(validate_message(empty_message).is_err());
    }
}
```

### 2. E2E 테스트
```typescript
// tests/e2e/chat.spec.ts
import { test, expect } from '@playwright/test';

test('should send and receive messages', async ({ page }) => {
  await page.goto('/');
  
  // 메시지 입력
  const input = page.locator('textarea[placeholder*="Claude"]');
  await input.fill('Hello, Claude!');
  
  // 전송 버튼 클릭
  await page.click('button[type="submit"]');
  
  // 사용자 메시지 확인
  await expect(page.locator('.prose:has-text("Hello, Claude!")')).toBeVisible();
  
  // AI 응답 대기 (최대 30초)
  await expect(page.locator('.prose').nth(1)).toBeVisible({ timeout: 30000 });
});
```

### 3. 빌드 및 배포
```bash
# 개발 모드
npm run tauri dev

# 프로덕션 빌드
npm run tauri build

# 특정 플랫폼 빌드
npm run tauri build -- --target x86_64-pc-windows-msvc
npm run tauri build -- --target x86_64-apple-darwin
npm run tauri build -- --target x86_64-unknown-linux-gnu
```

### 4. 자동 업데이트 설정
```json
// tauri.conf.json
{
  "tauri": {
    "updater": {
      "active": true,
      "endpoints": [
        "https://github.com/user/repo/releases/latest/download/latest.json"
      ],
      "dialog": true,
      "pubkey": "your-public-key-here"
    }
  }
}
```

### 5. CI/CD 파이프라인 (.github/workflows/build.yml)
```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        platform: [macos-latest, ubuntu-latest, windows-latest]
    
    runs-on: ${{ matrix.platform }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
          
      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build Tauri app
        run: npm run tauri build
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
          
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ${{ matrix.platform }}-build
          path: src-tauri/target/release/bundle/
```

## 마무리

이 가이드는 Claude API를 활용한 완전한 데스크톱 애플리케이션 개발의 모든 단계를 다뤘습니다. 추가적으로 고려할 사항들:

### 추가 기능 아이디어
- 대화 저장 및 불러오기
- 다크 모드 지원
- 다국어 지원
- 플러그인 시스템
- 음성 입력/출력
- 파일 업로드 지원

### 성능 최적화
- 메시지 압축
- 로컬 캐싱
- 백그라운드 동기화
- 메모리 누수 방지

이 가이드를 따라하면 프로덕션 수준의 Claude 채팅 애플리케이션을 개발할 수 있습니다.