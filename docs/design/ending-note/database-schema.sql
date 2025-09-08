-- ============================================================================
-- エンディングノート システム データベーススキーマ
-- MySQL 8.0+ 対応
-- ============================================================================

-- データベース作成（必要に応じて）
-- CREATE DATABASE ending_note CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE ending_note;

-- ============================================================================
-- 基本テーブル: ユーザー管理
-- ============================================================================

-- ユーザーテーブル
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE NOT NULL,
    encrypted_password VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    role ENUM('user', 'admin') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ユーザー認証トークンテーブル（JWT refresh token管理）
CREATE TABLE user_tokens (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    token_type ENUM('refresh', 'reset_password', 'email_verification') DEFAULT 'refresh',
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- プロフィール・基本情報テーブル
-- ============================================================================

-- プロフィールテーブル
CREATE TABLE profiles (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) UNIQUE NOT NULL,
    
    -- 基本情報（暗号化対象）
    first_name_encrypted TEXT,
    last_name_encrypted TEXT,
    first_name_kana_encrypted TEXT,
    last_name_kana_encrypted TEXT,
    date_of_birth_encrypted TEXT,
    blood_type ENUM('A', 'B', 'AB', 'O'),
    
    -- 連絡先情報（暗号化対象）
    postal_code_encrypted TEXT,
    prefecture_encrypted TEXT,
    city_encrypted TEXT,
    address_line1_encrypted TEXT,
    address_line2_encrypted TEXT,
    home_phone_encrypted TEXT,
    mobile_phone_encrypted TEXT,
    
    -- 戸籍情報（暗号化対象）
    registered_postal_code_encrypted TEXT,
    registered_prefecture_encrypted TEXT,
    registered_city_encrypted TEXT,
    registered_address_line1_encrypted TEXT,
    registered_address_line2_encrypted TEXT,
    
    -- 宗教・信仰
    religion ENUM('buddhism', 'christianity', 'shinto', 'other'),
    religious_sect_encrypted TEXT,
    temple_encrypted TEXT,
    
    -- その他
    notes_encrypted TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 緊急連絡先テーブル
-- ============================================================================

-- 緊急連絡先テーブル
CREATE TABLE emergency_contacts (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    
    -- 基本情報（暗号化対象）
    name_encrypted TEXT NOT NULL,
    name_kana_encrypted TEXT,
    relationship ENUM('spouse', 'child', 'parent', 'sibling', 'relative', 'friend', 'doctor', 'lawyer', 'other') NOT NULL,
    
    -- 連絡先情報（暗号化対象）
    primary_phone_encrypted TEXT,
    secondary_phone_encrypted TEXT,
    email_encrypted TEXT,
    
    -- 住所情報（暗号化対象）
    postal_code_encrypted TEXT,
    prefecture_encrypted TEXT,
    city_encrypted TEXT,
    address_line1_encrypted TEXT,
    address_line2_encrypted TEXT,
    
    priority INT DEFAULT 1,
    notes_encrypted TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 家系図テーブル群
-- ============================================================================

-- 家系図テーブル
CREATE TABLE family_trees (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    version INT DEFAULT 1,
    is_public BOOLEAN DEFAULT FALSE,
    last_modified_by CHAR(36),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (last_modified_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 家系図メンバーテーブル
CREATE TABLE family_members (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    family_tree_id CHAR(36) NOT NULL,
    
    -- 基本情報（暗号化対象）
    name_encrypted TEXT NOT NULL,
    name_kana_encrypted TEXT,
    date_of_birth_encrypted TEXT,
    date_of_death_encrypted TEXT,
    gender ENUM('male', 'female', 'other', 'unknown') DEFAULT 'unknown',
    is_alive BOOLEAN DEFAULT TRUE,
    
    -- 表示情報
    profile_photo_url TEXT,
    notes_encrypted TEXT,
    
    -- 家系図上の位置
    position_x FLOAT DEFAULT 0,
    position_y FLOAT DEFAULT 0,
    generation INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (family_tree_id) REFERENCES family_trees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 家系図関係テーブル
CREATE TABLE family_relationships (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    family_tree_id CHAR(36) NOT NULL,
    from_member_id CHAR(36) NOT NULL,
    to_member_id CHAR(36) NOT NULL,
    relationship_type ENUM('parent', 'child', 'spouse', 'sibling', 'adopted_child', 'step_parent', 'step_child') NOT NULL,
    start_date DATE,
    end_date DATE,
    notes_encrypted TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (family_tree_id) REFERENCES family_trees(id) ON DELETE CASCADE,
    FOREIGN KEY (from_member_id) REFERENCES family_members(id) ON DELETE CASCADE,
    FOREIGN KEY (to_member_id) REFERENCES family_members(id) ON DELETE CASCADE,
    
    -- 循環参照防止の制約
    CONSTRAINT chk_no_self_relationship CHECK (from_member_id != to_member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 家系図共有設定テーブル
CREATE TABLE family_tree_shares (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    family_tree_id CHAR(36) NOT NULL,
    shared_with_user_id CHAR(36),
    share_token VARCHAR(255) UNIQUE,
    permission ENUM('view', 'edit') DEFAULT 'view',
    expires_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (family_tree_id) REFERENCES family_trees(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_with_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- ファイル管理テーブル
-- ============================================================================

-- アップロードファイルテーブル
CREATE TABLE uploaded_files (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_name_encrypted TEXT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    storage_path TEXT NOT NULL,
    public_url TEXT,
    category ENUM('profile_photo', 'family_photo', 'document', 'other') DEFAULT 'other',
    description_encrypted TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 設定・環境設定テーブル
-- ============================================================================

-- ユーザー設定テーブル
CREATE TABLE user_settings (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) UNIQUE NOT NULL,
    
    -- 表示設定
    theme ENUM('light', 'dark', 'system') DEFAULT 'system',
    language ENUM('ja', 'en') DEFAULT 'ja',
    timezone VARCHAR(50) DEFAULT 'Asia/Tokyo',
    
    -- 通知設定
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT FALSE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    birthday_reminders BOOLEAN DEFAULT TRUE,
    anniversary_reminders BOOLEAN DEFAULT TRUE,
    profile_update_reminders BOOLEAN DEFAULT FALSE,
    
    -- プライバシー設定
    profile_visibility ENUM('private', 'family', 'public') DEFAULT 'private',
    share_analytics BOOLEAN DEFAULT FALSE,
    allow_family_tree_share BOOLEAN DEFAULT TRUE,
    
    -- アクセシビリティ設定
    font_size ENUM('small', 'medium', 'large', 'extra_large') DEFAULT 'medium',
    high_contrast BOOLEAN DEFAULT FALSE,
    reduce_motion BOOLEAN DEFAULT FALSE,
    screen_reader BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 監査・ログテーブル
-- ============================================================================

-- セキュリティ監査ログテーブル
CREATE TABLE audit_logs (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id CHAR(36),
    ip_address VARCHAR(45), -- IPv6対応
    user_agent TEXT,
    request_details JSON,
    response_status INT,
    severity ENUM('debug', 'info', 'warn', 'error', 'fatal') DEFAULT 'info',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- システムエラーログテーブル
CREATE TABLE error_logs (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    error_type VARCHAR(50) NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    request_path TEXT,
    request_method VARCHAR(10),
    user_id CHAR(36),
    ip_address VARCHAR(45), -- IPv6対応
    additional_context JSON,
    is_resolved BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- インデックス定義
-- ============================================================================

-- ユーザーテーブルのインデックス
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ユーザートークンテーブルのインデックス
CREATE INDEX idx_user_tokens_user_id ON user_tokens(user_id);
CREATE INDEX idx_user_tokens_token_type ON user_tokens(token_type);
CREATE INDEX idx_user_tokens_expires_at ON user_tokens(expires_at);
CREATE INDEX idx_user_tokens_is_revoked ON user_tokens(is_revoked);

-- プロフィールテーブルのインデックス
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);

-- 緊急連絡先テーブルのインデックス
CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts(user_id);
CREATE INDEX idx_emergency_contacts_relationship ON emergency_contacts(relationship);
CREATE INDEX idx_emergency_contacts_priority ON emergency_contacts(priority);
CREATE INDEX idx_emergency_contacts_is_active ON emergency_contacts(is_active);

-- 家系図テーブルのインデックス
CREATE INDEX idx_family_trees_user_id ON family_trees(user_id);
CREATE INDEX idx_family_trees_is_public ON family_trees(is_public);

-- 家系図メンバーテーブルのインデックス
CREATE INDEX idx_family_members_family_tree_id ON family_members(family_tree_id);
CREATE INDEX idx_family_members_gender ON family_members(gender);
CREATE INDEX idx_family_members_generation ON family_members(generation);

-- 家系図関係テーブルのインデックス
CREATE INDEX idx_family_relationships_family_tree_id ON family_relationships(family_tree_id);
CREATE INDEX idx_family_relationships_from_member_id ON family_relationships(from_member_id);
CREATE INDEX idx_family_relationships_to_member_id ON family_relationships(to_member_id);
CREATE INDEX idx_family_relationships_relationship_type ON family_relationships(relationship_type);

-- 家系図共有設定テーブルのインデックス
CREATE INDEX idx_family_tree_shares_family_tree_id ON family_tree_shares(family_tree_id);
CREATE INDEX idx_family_tree_shares_shared_with_user_id ON family_tree_shares(shared_with_user_id);
CREATE INDEX idx_family_tree_shares_share_token ON family_tree_shares(share_token);
CREATE INDEX idx_family_tree_shares_is_active ON family_tree_shares(is_active);

-- ファイルテーブルのインデックス
CREATE INDEX idx_uploaded_files_user_id ON uploaded_files(user_id);
CREATE INDEX idx_uploaded_files_category ON uploaded_files(category);
CREATE INDEX idx_uploaded_files_is_active ON uploaded_files(is_active);

-- 監査ログテーブルのインデックス
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_severity ON audit_logs(severity);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);

-- エラーログテーブルのインデックス
CREATE INDEX idx_error_logs_error_type ON error_logs(error_type);
CREATE INDEX idx_error_logs_is_resolved ON error_logs(is_resolved);
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at);

-- ============================================================================
-- ビュー定義
-- ============================================================================

-- アクティブなユーザープロフィールビュー（暗号化フィールドは除外）
CREATE VIEW active_user_profiles AS
SELECT 
    u.id,
    u.email,
    u.role,
    u.is_active,
    u.last_login_at,
    u.created_at,
    p.blood_type,
    p.religion,
    p.created_at as profile_created_at,
    p.updated_at as profile_updated_at
FROM users u
LEFT JOIN profiles p ON u.id = p.user_id
WHERE u.is_active = true;

-- 緊急連絡先サマリービュー
CREATE VIEW emergency_contacts_summary AS
SELECT 
    user_id,
    COUNT(*) as total_contacts,
    SUM(CASE WHEN relationship = 'spouse' THEN 1 ELSE 0 END) as spouse_count,
    SUM(CASE WHEN relationship = 'child' THEN 1 ELSE 0 END) as child_count,
    SUM(CASE WHEN relationship = 'parent' THEN 1 ELSE 0 END) as parent_count,
    SUM(CASE WHEN relationship = 'doctor' THEN 1 ELSE 0 END) as doctor_count,
    MIN(priority) as highest_priority
FROM emergency_contacts 
WHERE is_active = true
GROUP BY user_id;

-- ============================================================================
-- トリガー（MySQL形式）
-- ============================================================================

-- プロフィール変更監査トリガー
DELIMITER $$

CREATE TRIGGER audit_profile_changes_insert
AFTER INSERT ON profiles
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (user_id, action, resource_type, resource_id, request_details)
    VALUES (
        NEW.user_id,
        'profile_create',
        'profile',
        NEW.id,
        JSON_OBJECT('operation', 'INSERT')
    );
END$$

CREATE TRIGGER audit_profile_changes_update
AFTER UPDATE ON profiles
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (user_id, action, resource_type, resource_id, request_details)
    VALUES (
        NEW.user_id,
        'profile_update',
        'profile',
        NEW.id,
        JSON_OBJECT('operation', 'UPDATE')
    );
END$$

CREATE TRIGGER audit_profile_changes_delete
AFTER DELETE ON profiles
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (user_id, action, resource_type, resource_id, request_details)
    VALUES (
        OLD.user_id,
        'profile_delete',
        'profile',
        OLD.id,
        JSON_OBJECT('operation', 'DELETE')
    );
END$$

DELIMITER ;

-- ============================================================================
-- 暗号化・復号化関数（ストアドプロシージャ）
-- ============================================================================

DELIMITER $$

-- 暗号化関数
CREATE FUNCTION encrypt_pii(data TEXT, secret_key VARCHAR(255))
RETURNS TEXT
READS SQL DATA
DETERMINISTIC
BEGIN
    -- AES暗号化を使用（実際の実装ではより強固な暗号化を推奨）
    RETURN TO_BASE64(AES_ENCRYPT(data, secret_key));
END$$

-- 復号化関数
CREATE FUNCTION decrypt_pii(encrypted_data TEXT, secret_key VARCHAR(255))
RETURNS TEXT
READS SQL DATA
DETERMINISTIC
BEGIN
    -- AES復号化
    RETURN AES_DECRYPT(FROM_BASE64(encrypted_data), secret_key);
END$$

-- ユーザーバックアップ作成関数
CREATE PROCEDURE create_user_backup(IN target_user_id CHAR(36))
READS SQL DATA
BEGIN
    DECLARE backup_data JSON;
    
    SELECT JSON_OBJECT(
        'user', (SELECT JSON_OBJECT(
            'id', u.id,
            'email', u.email,
            'role', u.role,
            'created_at', u.created_at
        ) FROM users u WHERE id = target_user_id),
        'profile', (SELECT JSON_OBJECT(
            'id', p.id,
            'blood_type', p.blood_type,
            'religion', p.religion,
            'created_at', p.created_at
        ) FROM profiles p WHERE user_id = target_user_id),
        'emergency_contacts_count', (SELECT COUNT(*) FROM emergency_contacts WHERE user_id = target_user_id),
        'family_trees_count', (SELECT COUNT(*) FROM family_trees WHERE user_id = target_user_id),
        'created_at', NOW()
    ) INTO backup_data;
    
    -- 結果を返す
    SELECT backup_data as backup_json;
END$$

DELIMITER ;

-- ============================================================================
-- パーティショニング（監査ログテーブル）
-- ============================================================================

-- 月次パーティションテーブル（例）
-- ALTER TABLE audit_logs 
-- PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
--     PARTITION p202401 VALUES LESS THAN (202402),
--     PARTITION p202402 VALUES LESS THAN (202403),
--     PARTITION p202403 VALUES LESS THAN (202404)
-- );

-- ============================================================================
-- パフォーマンス最適化
-- ============================================================================

-- よく使用されるクエリ用の複合インデックス
CREATE INDEX idx_emergency_contacts_user_priority ON emergency_contacts(user_id, priority) WHERE is_active = true;
CREATE INDEX idx_family_trees_user_public ON family_trees(user_id, is_public);
CREATE INDEX idx_audit_logs_recent ON audit_logs(created_at DESC, user_id) WHERE created_at > DATE_SUB(NOW(), INTERVAL 30 DAY);

-- フルテキストインデックス（検索機能用）
-- ALTER TABLE family_members ADD FULLTEXT(name_encrypted);
-- ALTER TABLE emergency_contacts ADD FULLTEXT(name_encrypted);

-- ============================================================================
-- 統計情報とメンテナンス
-- ============================================================================

DELIMITER $$

-- テーブル統計情報更新プロシージャ
CREATE PROCEDURE update_table_statistics()
BEGIN
    ANALYZE TABLE users;
    ANALYZE TABLE profiles;
    ANALYZE TABLE emergency_contacts;
    ANALYZE TABLE family_trees;
    ANALYZE TABLE family_members;
    ANALYZE TABLE family_relationships;
    ANALYZE TABLE audit_logs;
END$$

-- 古いログデータクリーンアップ
CREATE PROCEDURE cleanup_old_logs()
BEGIN
    -- 1年以上前の監査ログを削除
    DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    -- 3ヶ月以上前のエラーログ（解決済み）を削除
    DELETE FROM error_logs 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 MONTH) 
    AND is_resolved = TRUE;
    
    -- 期限切れのトークンを削除
    DELETE FROM user_tokens WHERE expires_at < NOW();
END$$

DELIMITER ;

-- ============================================================================
-- コメント・ドキュメント
-- ============================================================================

-- テーブルコメント
ALTER TABLE users COMMENT = 'ユーザーアカウント情報を管理するテーブル';
ALTER TABLE profiles COMMENT = 'ユーザーの個人情報を暗号化して保存するテーブル';
ALTER TABLE emergency_contacts COMMENT = '緊急時連絡先情報を暗号化して保存するテーブル';
ALTER TABLE family_trees COMMENT = '家系図の基本情報を管理するテーブル';
ALTER TABLE family_members COMMENT = '家系図に含まれる人物情報を管理するテーブル';
ALTER TABLE family_relationships COMMENT = '家系図内の人物間の関係を定義するテーブル';
ALTER TABLE audit_logs COMMENT = 'セキュリティ監査ログを記録するテーブル';

-- カラムコメント例
ALTER TABLE profiles MODIFY COLUMN first_name_encrypted TEXT COMMENT '暗号化された名';
ALTER TABLE profiles MODIFY COLUMN last_name_encrypted TEXT COMMENT '暗号化された姓';
ALTER TABLE emergency_contacts MODIFY COLUMN priority INT DEFAULT 1 COMMENT '連絡優先度（1が最優先）';
ALTER TABLE family_members MODIFY COLUMN generation INT DEFAULT 0 COMMENT '世代レベル（0が基準世代）';

-- ============================================================================
-- 初期データ投入用
-- ============================================================================

-- システム管理者アカウント（必要に応じて）
-- INSERT INTO users (id, email, encrypted_password, role, is_active) 
-- VALUES (UUID(), 'admin@example.com', 'encrypted_password_here', 'admin', TRUE);

-- デフォルト設定値
-- INSERT IGNORE INTO user_settings (id, user_id) 
-- SELECT UUID(), id FROM users WHERE role = 'user';

-- ============================================================================
-- バックアップ・復旧スクリプト
-- ============================================================================

-- バックアップスクリプト（実行例）
-- mysqldump -u username -p --single-transaction --routines --triggers ending_note > ending_note_backup_$(date +%Y%m%d).sql

-- 復旧スクリプト（実行例）
-- mysql -u username -p ending_note < ending_note_backup_20240115.sql