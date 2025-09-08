# API エンドポイント仕様

## 基本情報

- **Base URL**: `https://api.ending-note.example.com`
- **API Version**: `v1`
- **Protocol**: HTTPS only
- **Content-Type**: `application/json`
- **Character Encoding**: UTF-8

## 認証

### JWT Bearer Token認証

```
Authorization: Bearer <access_token>
```

### レスポンス形式

すべてのAPIレスポンスは以下の統一形式を使用：

```json
{
  "success": boolean,
  "data": any,
  "error": {
    "code": "string",
    "message": "string",
    "details": {}
  },
  "pagination": {
    "currentPage": number,
    "totalPages": number,
    "totalItems": number,
    "itemsPerPage": number
  }
}
```

## ステータスコード

- `200` OK - 成功
- `201` Created - 作成成功
- `204` No Content - 更新/削除成功
- `400` Bad Request - リクエスト不正
- `401` Unauthorized - 未認証
- `403` Forbidden - 権限不足
- `404` Not Found - リソース不存在
- `422` Unprocessable Entity - バリデーションエラー
- `429` Too Many Requests - レート制限
- `500` Internal Server Error - サーバーエラー

---

## 認証エンドポイント

### POST /auth/register

ユーザー登録

**リクエスト:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "passwordConfirmation": "SecurePassword123!"
}
```

**レスポンス (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "emailVerified": false,
      "role": "user",
      "createdAt": "2024-01-15T10:30:00Z"
    },
    "tokens": {
      "accessToken": "jwt_access_token",
      "refreshToken": "jwt_refresh_token",
      "expiresIn": 3600
    }
  }
}
```

### POST /auth/login

ユーザーログイン

**リクエスト:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "rememberMe": true
}
```

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "emailVerified": true,
      "role": "user",
      "lastLoginAt": "2024-01-15T10:30:00Z"
    },
    "tokens": {
      "accessToken": "jwt_access_token",
      "refreshToken": "jwt_refresh_token",
      "expiresIn": 3600
    }
  }
}
```

### POST /auth/refresh

トークンリフレッシュ

**リクエスト:**
```json
{
  "refreshToken": "jwt_refresh_token"
}
```

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "new_jwt_access_token",
    "expiresIn": 3600
  }
}
```

### POST /auth/logout

ログアウト

**ヘッダー:**
```
Authorization: Bearer <access_token>
```

**レスポンス (204):**
空のレスポンス

### POST /auth/forgot-password

パスワードリセット要求

**リクエスト:**
```json
{
  "email": "user@example.com"
}
```

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "message": "パスワードリセット用のメールを送信しました"
  }
}
```

---

## ユーザープロフィール

### GET /api/v1/profile

現在のユーザーのプロフィール取得

**ヘッダー:**
```
Authorization: Bearer <access_token>
```

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "firstName": "太郎",
    "lastName": "山田",
    "firstNameKana": "タロウ",
    "lastNameKana": "ヤマダ",
    "dateOfBirth": "1980-05-15",
    "bloodType": "A",
    "postalCode": "123-4567",
    "prefecture": "東京都",
    "city": "渋谷区",
    "addressLine1": "神南1-2-3",
    "homePhone": "03-1234-5678",
    "mobilePhone": "090-1234-5678",
    "religion": "buddhism",
    "religiousSect": "浄土宗",
    "temple": "○○寺",
    "notes": "特記事項なし",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### POST /api/v1/profile

プロフィール作成

**リクエスト:**
```json
{
  "firstName": "太郎",
  "lastName": "山田",
  "firstNameKana": "タロウ",
  "lastNameKana": "ヤマダ",
  "dateOfBirth": "1980-05-15",
  "bloodType": "A",
  "postalCode": "123-4567",
  "prefecture": "東京都",
  "city": "渋谷区",
  "addressLine1": "神南1-2-3",
  "homePhone": "03-1234-5678",
  "mobilePhone": "090-1234-5678",
  "religion": "buddhism",
  "religiousSect": "浄土宗",
  "temple": "○○寺"
}
```

**レスポンス (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "firstName": "太郎",
    "lastName": "山田",
    // ... その他のフィールド
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### PUT /api/v1/profile

プロフィール更新

**リクエスト:**
```json
{
  "mobilePhone": "090-9999-8888",
  "notes": "更新された特記事項"
}
```

**レスポンス (200):**
更新されたプロフィールオブジェクト

### DELETE /api/v1/profile

プロフィール削除

**レスポンス (204):**
空のレスポンス

---

## 緊急連絡先

### GET /api/v1/emergency-contacts

緊急連絡先一覧取得

**クエリパラメータ:**
- `page`: ページ番号 (default: 1)
- `limit`: 1ページあたりの件数 (default: 20)
- `relationship`: 関係でフィルタ
- `sort`: ソート順 (`priority_asc`, `priority_desc`, `name_asc`, `name_desc`)

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "contacts": [
      {
        "id": "uuid",
        "userId": "uuid",
        "name": "田中花子",
        "nameKana": "タナカハナコ",
        "relationship": "spouse",
        "primaryPhone": "090-1111-2222",
        "email": "hanako@example.com",
        "priority": 1,
        "isActive": true,
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ]
  },
  "pagination": {
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 5,
    "itemsPerPage": 20
  }
}
```

### POST /api/v1/emergency-contacts

緊急連絡先追加

**リクエスト:**
```json
{
  "name": "田中花子",
  "nameKana": "タナカハナコ",
  "relationship": "spouse",
  "primaryPhone": "090-1111-2222",
  "secondaryPhone": "03-5555-6666",
  "email": "hanako@example.com",
  "address": {
    "postalCode": "123-4567",
    "prefecture": "東京都",
    "city": "新宿区",
    "addressLine1": "歌舞伎町1-1-1"
  },
  "priority": 1,
  "notes": "配偶者"
}
```

**レスポンス (201):**
作成された緊急連絡先オブジェクト

### GET /api/v1/emergency-contacts/:id

特定の緊急連絡先取得

**レスポンス (200):**
緊急連絡先オブジェクト

### PUT /api/v1/emergency-contacts/:id

緊急連絡先更新

**リクエスト:**
```json
{
  "primaryPhone": "090-9999-8888",
  "priority": 2
}
```

**レスポンス (200):**
更新された緊急連絡先オブジェクト

### DELETE /api/v1/emergency-contacts/:id

緊急連絡先削除

**レスポンス (204):**
空のレスポンス

### PUT /api/v1/emergency-contacts/reorder

緊急連絡先の優先度一括更新

**リクエスト:**
```json
{
  "contacts": [
    { "id": "uuid1", "priority": 1 },
    { "id": "uuid2", "priority": 2 },
    { "id": "uuid3", "priority": 3 }
  ]
}
```

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "message": "優先度を更新しました",
    "updatedCount": 3
  }
}
```

---

## 家系図

### GET /api/v1/family-trees

家系図一覧取得

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "familyTrees": [
      {
        "id": "uuid",
        "userId": "uuid",
        "name": "山田家家系図",
        "description": "祖父の代からの家系図",
        "version": 2,
        "isPublic": false,
        "memberCount": 15,
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-20T15:45:00Z"
      }
    ]
  }
}
```

### POST /api/v1/family-trees

家系図作成

**リクエスト:**
```json
{
  "name": "山田家家系図",
  "description": "祖父の代からの家系図"
}
```

**レスポンス (201):**
作成された家系図オブジェクト

### GET /api/v1/family-trees/:id

特定の家系図取得（メンバーと関係を含む）

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "name": "山田家家系図",
    "description": "祖父の代からの家系図",
    "version": 2,
    "isPublic": false,
    "members": [
      {
        "id": "uuid",
        "familyTreeId": "uuid",
        "name": "山田太郎",
        "nameKana": "ヤマダタロウ",
        "dateOfBirth": "1980-05-15",
        "gender": "male",
        "isAlive": true,
        "position": {
          "x": 100,
          "y": 200,
          "generation": 0
        },
        "profilePhoto": "https://example.com/photos/taro.jpg",
        "notes": "現世代",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "relationships": [
      {
        "id": "uuid",
        "familyTreeId": "uuid",
        "fromMemberId": "uuid1",
        "toMemberId": "uuid2",
        "relationshipType": "parent",
        "startDate": "1980-05-15",
        "notes": "実父",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "metadata": {
      "version": 2,
      "lastModifiedBy": "uuid",
      "isPublic": false
    },
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}
```

### PUT /api/v1/family-trees/:id

家系図更新

**リクエスト:**
```json
{
  "name": "山田家家系図（更新版）",
  "description": "曾祖父の代からの家系図"
}
```

**レスポンス (200):**
更新された家系図オブジェクト

### DELETE /api/v1/family-trees/:id

家系図削除

**レスポンス (204):**
空のレスポンス

### POST /api/v1/family-trees/:id/members

家系図メンバー追加

**リクエスト:**
```json
{
  "name": "山田花子",
  "nameKana": "ヤマダハナコ",
  "dateOfBirth": "1985-08-20",
  "gender": "female",
  "isAlive": true,
  "position": {
    "x": 200,
    "y": 200,
    "generation": 0
  },
  "notes": "配偶者"
}
```

**レスポンス (201):**
作成されたメンバーオブジェクト

### PUT /api/v1/family-trees/:treeId/members/:memberId

家系図メンバー更新

**リクエスト:**
```json
{
  "position": {
    "x": 250,
    "y": 180,
    "generation": 0
  },
  "notes": "更新された情報"
}
```

**レスポンス (200):**
更新されたメンバーオブジェクト

### DELETE /api/v1/family-trees/:treeId/members/:memberId

家系図メンバー削除

**レスポンス (204):**
空のレスポンス

### POST /api/v1/family-trees/:id/relationships

家系図関係追加

**リクエスト:**
```json
{
  "fromMemberId": "uuid1",
  "toMemberId": "uuid2",
  "relationshipType": "spouse",
  "startDate": "2010-06-15",
  "notes": "結婚"
}
```

**レスポンス (201):**
作成された関係オブジェクト

### PUT /api/v1/family-trees/:treeId/relationships/:relationshipId

家系図関係更新

**レスポンス (200):**
更新された関係オブジェクト

### DELETE /api/v1/family-trees/:treeId/relationships/:relationshipId

家系図関係削除

**レスポンス (204):**
空のレスポンス

---

## ファイル管理

### POST /api/v1/files/upload

ファイルアップロード

**Content-Type:** `multipart/form-data`

**フィールド:**
- `file`: ファイルデータ
- `category`: ファイルカテゴリ (`profile_photo`, `family_photo`, `document`, `other`)
- `description`: ファイル説明（オプション）

**レスポンス (201):**
```json
{
  "success": true,
  "data": {
    "file": {
      "id": "uuid",
      "userId": "uuid",
      "filename": "generated_filename.jpg",
      "originalName": "family_photo.jpg",
      "mimeType": "image/jpeg",
      "size": 1024000,
      "url": "https://cdn.example.com/files/uuid/generated_filename.jpg",
      "category": "family_photo",
      "description": "家族写真",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

### GET /api/v1/files

ファイル一覧取得

**クエリパラメータ:**
- `category`: カテゴリフィルタ
- `page`: ページ番号
- `limit`: 1ページあたりの件数

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "files": [
      {
        "id": "uuid",
        "filename": "generated_filename.jpg",
        "originalName": "family_photo.jpg",
        "url": "https://cdn.example.com/files/uuid/generated_filename.jpg",
        "category": "family_photo",
        "size": 1024000,
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### DELETE /api/v1/files/:id

ファイル削除

**レスポンス (204):**
空のレスポンス

---

## 設定

### GET /api/v1/settings

ユーザー設定取得

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "theme": "light",
    "language": "ja",
    "timezone": "Asia/Tokyo",
    "notifications": {
      "email": true,
      "push": false,
      "sms": false,
      "reminderSettings": {
        "birthdays": true,
        "anniversaries": true,
        "profileUpdates": false
      }
    },
    "privacy": {
      "profileVisibility": "private",
      "shareAnalytics": false,
      "allowFamilyTreeShare": true
    },
    "accessibility": {
      "fontSize": "medium",
      "highContrast": false,
      "reduceMotion": false,
      "screenReader": false
    }
  }
}
```

### PUT /api/v1/settings

ユーザー設定更新

**リクエスト:**
```json
{
  "theme": "dark",
  "accessibility": {
    "fontSize": "large",
    "highContrast": true
  }
}
```

**レスポンス (200):**
更新された設定オブジェクト

---

## 検索・エクスポート

### GET /api/v1/search

全体検索

**クエリパラメータ:**
- `q`: 検索キーワード
- `types`: 検索対象タイプ (`profile,contacts,family_trees`)
- `page`: ページ番号
- `limit`: 1ページあたりの件数

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "type": "emergency_contact",
        "id": "uuid",
        "title": "田中花子",
        "description": "緊急連絡先 - 配偶者",
        "relevance": 0.95
      }
    ],
    "totalResults": 10
  }
}
```

### POST /api/v1/export

データエクスポート

**リクエスト:**
```json
{
  "format": "json",
  "includePhotos": true,
  "includeNotes": true,
  "dateRange": {
    "from": "2024-01-01",
    "to": "2024-12-31"
  }
}
```

**レスポンス (200):**
```json
{
  "success": true,
  "data": {
    "url": "https://exports.example.com/user_data_20240115.json",
    "filename": "user_data_20240115.json",
    "size": 2048000,
    "expiresAt": "2024-01-22T10:30:00Z"
  }
}
```

---

## エラーレスポンス例

### バリデーションエラー (422)

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力データに不正があります",
    "details": {
      "email": ["メールアドレスの形式が正しくありません"],
      "password": ["パスワードは8文字以上である必要があります"]
    }
  }
}
```

### 認証エラー (401)

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "認証が必要です"
  }
}
```

### 権限エラー (403)

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "このリソースにアクセスする権限がありません"
  }
}
```

### リソース不存在エラー (404)

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "指定されたリソースが見つかりません"
  }
}
```

### サーバーエラー (500)

```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "内部サーバーエラーが発生しました"
  }
}
```

---

## レート制限

- 認証済みユーザー: 1000 requests/hour
- 未認証ユーザー: 100 requests/hour
- ファイルアップロード: 10 requests/hour

制限に達した場合は `429 Too Many Requests` を返す。

## バージョニング

APIのバージョンはURLパスに含める（`/api/v1/`）。
メジャーバージョンアップ時は新しいエンドポイントを作成し、旧バージョンは段階的に廃止。

## セキュリティヘッダー

すべてのレスポンスに以下のセキュリティヘッダーを含める：

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
```