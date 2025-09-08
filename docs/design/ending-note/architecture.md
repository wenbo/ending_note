# エンディングノート アーキテクチャ設計

## システム概要

エンディングノートシステムは、終活を行う個人が自身の基本情報、緊急連絡先、家系図を安全に記録・管理できるWebアプリケーションです。個人情報保護を重視し、直感的で高齢者にも使いやすいインターフェースを提供します。

## アーキテクチャパターン

- **パターン**: Model-View-Controller (MVC) + API First
- **理由**: 
  - Rails既存プロジェクトとの親和性が高い
  - フロントエンドとバックエンドの明確な分離
  - 将来的なモバイルアプリ対応が容易
  - 個人情報を扱うためセキュリティ境界の明確化が重要

## システム構成図

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   フロントエンド  │    │   バックエンド    │    │   データベース   │
│                 │    │                 │    │                 │
│ - React 18      │◄───┤ - Ruby on Rails │◄───┤ - MySQL 8.0     │
│ - TypeScript    │    │ - API サーバー   │    │ - Redis (cache) │
│ - Vite + SPA    │    │ - 認証・認可     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CDN/Static    │    │  Load Balancer  │    │   Backup        │
│   Asset Hosting │    │  SSL Termination│    │   日次バックアップ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## コンポーネント構成

### フロントエンド

- **フレームワーク**: React 18
- **言語**: TypeScript
- **ビルドツール**: Vite
- **スタイリング**: Tailwind CSS
- **状態管理**: React Query (TanStack Query) + Zustand
- **フォーム管理**: React Hook Form + Zod
- **UI コンポーネント**: Shadcn/ui + Radix UI
- **ルーティング**: React Router v6
- **認証**: カスタム認証フック + JWT

**選択理由**:
- シンプルで軽量なSPA構成
- TypeScriptによる型安全性
- Viteによる高速な開発体験
- 高齢者向けの大きなフォントサイズとアクセシビリティ対応
- モバイルファーストなレスポンシブデザイン

### バックエンド

- **フレームワーク**: Ruby on Rails 7.1 (API mode)
- **認証方式**: JWT + Rails Devise
- **API**: RESTful API with JSON:API specification
- **バリデーション**: Rails validations + custom validators
- **セキュリティ**: Rails security features + custom middleware
- **ファイルストレージ**: Active Storage with S3

**選択理由**:
- 既存のRailsプロジェクトとの統合性
- 強力なセキュリティ機能
- 豊富なgemによる開発効率
- 個人情報保護法対応の容易さ

### データベース

- **RDBMS**: MySQL 8.0
- **キャッシュ**: Redis 7
- **検索**: MySQL Full-Text Search
- **バックアップ**: mysqldump + 暗号化

**選択理由**:
- ACIDトランザクション保証
- 高いパフォーマンスと安定性
- JSON型による柔軟な家系図データ保存
- 広く普及しており運用実績が豊富
- Rails ActiveRecordとの親和性

## セキュリティアーキテクチャ

### 認証・認可

```
User Request → HTTPS → Load Balancer → Rails API
                                         ↓
                                    JWT Validation
                                         ↓
                                    Authorization Check
                                         ↓
                                    Data Access Control
```

### データ保護

- **暗号化**: 
  - 通信: TLS 1.3
  - データベース: 列レベル暗号化 (個人情報)
  - パスワード: bcrypt
- **アクセス制御**: Role-based (RBAC)
- **監査ログ**: 全ての個人情報アクセスをログ記録

## スケーラビリティ

### 水平スケーリング戦略

- **アプリケーション**: ステートレス設計によるマルチインスタンス
- **データベース**: Read Replica + Connection Pooling
- **キャッシュ**: Redis Cluster
- **ファイル**: CDN + オブジェクトストレージ

### パフォーマンス最適化

- **フロントエンド**: 
  - Code splitting (React.lazy + Suspense)
  - Bundle optimization (Vite tree-shaking)
  - Image optimization (WebP対応)
  - Virtual scrolling (大量データ表示)
- **バックエンド**:
  - Database indexing
  - Query optimization
  - Background jobs (Sidekiq)

## 運用・監視

### 監視項目

- **アプリケーションメトリクス**: レスポンス時間, エラー率
- **インフラメトリクス**: CPU, メモリ, ディスク使用率
- **セキュリティ**: 不正アクセス検知, 異常ログイン
- **ビジネスメトリクス**: ユーザー登録数, 機能利用率

### ログ管理

- **構造化ログ**: JSON形式
- **ログレベル**: DEBUG, INFO, WARN, ERROR, FATAL
- **個人情報マスキング**: 自動的にPII情報をマスク
- **保存期間**: セキュリティログ1年, アプリケーションログ3ヶ月

## デプロイメント

### 環境構成

- **Development**: ローカル開発環境
- **Staging**: 本番類似環境でのテスト
- **Production**: 本番環境

### CI/CD パイプライン

```
Git Push → GitHub Actions → Test → Build → Deploy
                              ↓
                         Security Scan
                              ↓
                        Database Migration
                              ↓
                        Health Check
```

## 災害復旧

### バックアップ戦略

- **データベース**: 日次フルバックアップ + バイナリログ継続バックアップ
- **ファイル**: オブジェクトストレージの自動レプリケーション
- **設定**: Infrastructure as Code (Terraform)

### 復旧目標

- **RTO (Recovery Time Objective)**: 4時間
- **RPO (Recovery Point Objective)**: 1時間
- **可用性目標**: 99.0%