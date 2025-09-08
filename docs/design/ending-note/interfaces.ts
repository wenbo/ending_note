// ============================================================================
// エンディングノート システム TypeScript型定義
// ============================================================================

// 基本型定義
export type ID = string;
export type Timestamp = string; // ISO 8601形式
export type Email = string;
export type PhoneNumber = string;
export type PostalCode = string;

// ============================================================================
// 共通型
// ============================================================================

export interface BaseEntity {
  id: ID;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: ApiError;
  pagination?: PaginationInfo;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, string[]>;
}

export interface PaginationInfo {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
}

// ============================================================================
// 認証・ユーザー関連
// ============================================================================

export interface User extends BaseEntity {
  email: Email;
  emailVerified: boolean;
  lastLoginAt?: Timestamp;
  profileId?: ID;
  role: UserRole;
  isActive: boolean;
}

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin'
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface LoginRequest {
  email: Email;
  password: string;
  rememberMe?: boolean;
}

export interface LoginResponse extends ApiResponse<{
  user: User;
  tokens: AuthTokens;
}> {}

export interface RegisterRequest {
  email: Email;
  password: string;
  passwordConfirmation: string;
}

// ============================================================================
// プロフィール・基本情報
// ============================================================================

export interface Profile extends BaseEntity {
  userId: ID;
  // 基本情報
  firstName: string;
  lastName: string;
  firstNameKana?: string;
  lastNameKana?: string;
  dateOfBirth?: string; // YYYY-MM-DD
  bloodType?: BloodType;
  
  // 連絡先情報
  postalCode?: PostalCode;
  prefecture?: string;
  city?: string;
  addressLine1?: string;
  addressLine2?: string;
  homePhone?: PhoneNumber;
  mobilePhone?: PhoneNumber;
  
  // 戸籍情報
  registeredAddress?: Address;
  
  // 宗教・信仰
  religion?: Religion;
  religiousSect?: string;
  temple?: string;
  
  // その他
  notes?: string;
}

export enum BloodType {
  A = 'A',
  B = 'B',
  AB = 'AB',
  O = 'O'
}

export enum Religion {
  BUDDHISM = 'buddhism',
  CHRISTIANITY = 'christianity',
  SHINTO = 'shinto',
  OTHER = 'other'
}

export interface Address {
  postalCode?: PostalCode;
  prefecture?: string;
  city?: string;
  addressLine1?: string;
  addressLine2?: string;
}

export interface CreateProfileRequest {
  firstName: string;
  lastName: string;
  firstNameKana?: string;
  lastNameKana?: string;
  dateOfBirth?: string;
  bloodType?: BloodType;
  postalCode?: PostalCode;
  prefecture?: string;
  city?: string;
  addressLine1?: string;
  addressLine2?: string;
  homePhone?: PhoneNumber;
  mobilePhone?: PhoneNumber;
  religion?: Religion;
  religiousSect?: string;
  temple?: string;
  notes?: string;
}

export interface UpdateProfileRequest extends Partial<CreateProfileRequest> {}

// ============================================================================
// 緊急連絡先
// ============================================================================

export interface EmergencyContact extends BaseEntity {
  userId: ID;
  name: string;
  nameKana?: string;
  relationship: ContactRelationship;
  primaryPhone?: PhoneNumber;
  secondaryPhone?: PhoneNumber;
  email?: Email;
  address?: Address;
  priority: number; // 1が最優先
  notes?: string;
  isActive: boolean;
}

export enum ContactRelationship {
  SPOUSE = 'spouse',
  CHILD = 'child',
  PARENT = 'parent',
  SIBLING = 'sibling',
  RELATIVE = 'relative',
  FRIEND = 'friend',
  DOCTOR = 'doctor',
  LAWYER = 'lawyer',
  OTHER = 'other'
}

export interface CreateEmergencyContactRequest {
  name: string;
  nameKana?: string;
  relationship: ContactRelationship;
  primaryPhone?: PhoneNumber;
  secondaryPhone?: PhoneNumber;
  email?: Email;
  address?: Address;
  priority?: number;
  notes?: string;
}

export interface UpdateEmergencyContactRequest extends Partial<CreateEmergencyContactRequest> {}

export interface EmergencyContactListResponse extends ApiResponse<{
  contacts: EmergencyContact[];
}> {}

// ============================================================================
// 家系図
// ============================================================================

export interface FamilyTree extends BaseEntity {
  userId: ID;
  name: string; // 家系図の名前
  description?: string;
  members: FamilyMember[];
  relationships: FamilyRelationship[];
  metadata: FamilyTreeMetadata;
}

export interface FamilyMember extends BaseEntity {
  familyTreeId: ID;
  name: string;
  nameKana?: string;
  dateOfBirth?: string;
  dateOfDeath?: string;
  gender: Gender;
  isAlive: boolean;
  profilePhoto?: string; // 写真のURL
  notes?: string;
  position: Position; // 家系図上の位置
}

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  OTHER = 'other',
  UNKNOWN = 'unknown'
}

export interface Position {
  x: number;
  y: number;
  generation: number; // 世代レベル (0が基準世代)
}

export interface FamilyRelationship extends BaseEntity {
  familyTreeId: ID;
  fromMemberId: ID;
  toMemberId: ID;
  relationshipType: RelationshipType;
  startDate?: string;
  endDate?: string;
  notes?: string;
}

export enum RelationshipType {
  PARENT = 'parent',
  CHILD = 'child',
  SPOUSE = 'spouse',
  SIBLING = 'sibling',
  ADOPTED_CHILD = 'adopted_child',
  STEP_PARENT = 'step_parent',
  STEP_CHILD = 'step_child'
}

export interface FamilyTreeMetadata {
  version: number;
  lastModifiedBy: ID;
  isPublic: boolean;
  shareSettings?: ShareSettings;
}

export interface ShareSettings {
  isShared: boolean;
  allowedUsers: ID[];
  shareToken?: string;
  expiresAt?: Timestamp;
}

export interface CreateFamilyTreeRequest {
  name: string;
  description?: string;
}

export interface UpdateFamilyTreeRequest extends Partial<CreateFamilyTreeRequest> {}

export interface AddFamilyMemberRequest {
  name: string;
  nameKana?: string;
  dateOfBirth?: string;
  dateOfDeath?: string;
  gender: Gender;
  isAlive?: boolean;
  profilePhoto?: string;
  notes?: string;
  position: Position;
}

export interface AddFamilyRelationshipRequest {
  fromMemberId: ID;
  toMemberId: ID;
  relationshipType: RelationshipType;
  startDate?: string;
  endDate?: string;
  notes?: string;
}

// ============================================================================
// ファイル管理
// ============================================================================

export interface FileUpload {
  file: File;
  category: FileCategory;
  description?: string;
}

export enum FileCategory {
  PROFILE_PHOTO = 'profile_photo',
  FAMILY_PHOTO = 'family_photo',
  DOCUMENT = 'document',
  OTHER = 'other'
}

export interface UploadedFile extends BaseEntity {
  userId: ID;
  filename: string;
  originalName: string;
  mimeType: string;
  size: number;
  url: string;
  category: FileCategory;
  description?: string;
}

export interface FileUploadResponse extends ApiResponse<{
  file: UploadedFile;
}> {}

// ============================================================================
// 検索・フィルタリング
// ============================================================================

export interface SearchQuery {
  q?: string;
  filters?: SearchFilters;
  sort?: SortOptions;
  page?: number;
  limit?: number;
}

export interface SearchFilters {
  relationship?: ContactRelationship[];
  bloodType?: BloodType[];
  religion?: Religion[];
  isActive?: boolean;
  createdAfter?: Timestamp;
  createdBefore?: Timestamp;
}

export interface SortOptions {
  field: string;
  order: 'asc' | 'desc';
}

export interface SearchResponse<T> extends ApiResponse<{
  items: T[];
  query: SearchQuery;
}> {}

// ============================================================================
// 設定・環境設定
// ============================================================================

export interface UserSettings extends BaseEntity {
  userId: ID;
  theme: Theme;
  language: Language;
  timezone: string;
  notifications: NotificationSettings;
  privacy: PrivacySettings;
  accessibility: AccessibilitySettings;
}

export enum Theme {
  LIGHT = 'light',
  DARK = 'dark',
  SYSTEM = 'system'
}

export enum Language {
  JA = 'ja',
  EN = 'en'
}

export interface NotificationSettings {
  email: boolean;
  push: boolean;
  sms: boolean;
  reminderSettings: ReminderSettings;
}

export interface ReminderSettings {
  birthdays: boolean;
  anniversaries: boolean;
  profileUpdates: boolean;
}

export interface PrivacySettings {
  profileVisibility: ProfileVisibility;
  shareAnalytics: boolean;
  allowFamilyTreeShare: boolean;
}

export enum ProfileVisibility {
  PRIVATE = 'private',
  FAMILY = 'family',
  PUBLIC = 'public'
}

export interface AccessibilitySettings {
  fontSize: FontSize;
  highContrast: boolean;
  reduceMotion: boolean;
  screenReader: boolean;
}

export enum FontSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large',
  EXTRA_LARGE = 'extra_large'
}

// ============================================================================
// バリデーションスキーマ (Zod用)
// ============================================================================

export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
}

// ============================================================================
// 状態管理 (Zustand用)
// ============================================================================

export interface AuthState {
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: LoginRequest) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
}

export interface ProfileState {
  profile: Profile | null;
  isLoading: boolean;
  error: string | null;
  fetchProfile: () => Promise<void>;
  updateProfile: (data: UpdateProfileRequest) => Promise<void>;
  clearError: () => void;
}

export interface EmergencyContactState {
  contacts: EmergencyContact[];
  isLoading: boolean;
  error: string | null;
  fetchContacts: () => Promise<void>;
  addContact: (data: CreateEmergencyContactRequest) => Promise<void>;
  updateContact: (id: ID, data: UpdateEmergencyContactRequest) => Promise<void>;
  deleteContact: (id: ID) => Promise<void>;
  reorderContacts: (contacts: EmergencyContact[]) => Promise<void>;
}

export interface FamilyTreeState {
  familyTrees: FamilyTree[];
  currentTree: FamilyTree | null;
  isLoading: boolean;
  error: string | null;
  fetchFamilyTrees: () => Promise<void>;
  createFamilyTree: (data: CreateFamilyTreeRequest) => Promise<void>;
  updateFamilyTree: (id: ID, data: UpdateFamilyTreeRequest) => Promise<void>;
  deleteFamilyTree: (id: ID) => Promise<void>;
  setCurrentTree: (tree: FamilyTree | null) => void;
  addMember: (data: AddFamilyMemberRequest) => Promise<void>;
  updateMember: (id: ID, data: Partial<FamilyMember>) => Promise<void>;
  deleteMember: (id: ID) => Promise<void>;
  addRelationship: (data: AddFamilyRelationshipRequest) => Promise<void>;
  updateRelationship: (id: ID, data: Partial<FamilyRelationship>) => Promise<void>;
  deleteRelationship: (id: ID) => Promise<void>;
}

// ============================================================================
// React コンポーネント Props
// ============================================================================

// React types will be imported in the actual implementation files

export interface FormProps<T = any> {
  initialData?: T;
  onSubmit: (data: T) => void | Promise<void>;
  onCancel?: () => void;
  isLoading?: boolean;
  error?: string | null;
  className?: string;
}

export interface ListProps<T = any> {
  items: T[];
  isLoading?: boolean;
  error?: string | null;
  onItemClick?: (item: T) => void;
  onItemEdit?: (item: T) => void;
  onItemDelete?: (item: T) => void;
  pagination?: PaginationInfo;
  onPageChange?: (page: number) => void;
  className?: string;
}

export interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  size?: 'small' | 'medium' | 'large' | 'full';
  children: React.ReactNode;
  className?: string;
}

export interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  className?: string;
}

export interface InputProps {
  name: string;
  type?: 'text' | 'email' | 'password' | 'tel' | 'number' | 'date';
  placeholder?: string;
  value?: string;
  defaultValue?: string;
  onChange?: (value: string) => void;
  onBlur?: () => void;
  required?: boolean;
  disabled?: boolean;
  error?: string;
  className?: string;
}

export interface SelectProps {
  name: string;
  options: Array<{
    value: string;
    label: string;
    disabled?: boolean;
  }>;
  value?: string;
  defaultValue?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  required?: boolean;
  disabled?: boolean;
  error?: string;
  className?: string;
}

// ============================================================================
// ルーティング関連 (React Router)
// ============================================================================

export interface RouteParams {
  id?: string;
  treeId?: string;
  memberId?: string;
  contactId?: string;
}

export interface NavigationItem {
  path: string;
  label: string;
  icon?: string;
  children?: NavigationItem[];
  requiredPermissions?: string[];
}

export interface BreadcrumbItem {
  label: string;
  path?: string;
  active?: boolean;
}

export interface PageProps {
  title?: string;
  breadcrumbs?: BreadcrumbItem[];
  children: React.ReactNode;
  className?: string;
}

// ============================================================================
// React Query / API関連
// ============================================================================

export interface QueryOptions {
  enabled?: boolean;
  refetchOnWindowFocus?: boolean;
  refetchOnMount?: boolean;
  staleTime?: number;
  cacheTime?: number;
}

export interface MutationOptions<TData = any, TError = any, TVariables = any> {
  onSuccess?: (data: TData, variables: TVariables) => void;
  onError?: (error: TError, variables: TVariables) => void;
  onMutate?: (variables: TVariables) => void;
}

export interface InfiniteQueryOptions extends QueryOptions {
  getNextPageParam?: (lastPage: any, pages: any[]) => any;
  getPreviousPageParam?: (firstPage: any, pages: any[]) => any;
}

// ============================================================================
// Vite / Build関連
// ============================================================================

export interface BuildConfig {
  apiBaseUrl: string;
  appVersion: string;
  environment: 'development' | 'staging' | 'production';
  features: {
    enableAnalytics: boolean;
    enablePWA: boolean;
    enableServiceWorker: boolean;
  };
}

export interface EnvironmentVariables {
  VITE_API_BASE_URL: string;
  VITE_APP_VERSION: string;
  VITE_ENVIRONMENT: string;
  VITE_ENABLE_ANALYTICS: string;
  VITE_ENABLE_PWA: string;
}

// ============================================================================
// エクスポート・インポート
// ============================================================================

export interface ExportOptions {
  format: ExportFormat;
  includePhotos: boolean;
  includeNotes: boolean;
  dateRange?: {
    from: string;
    to: string;
  };
}

export enum ExportFormat {
  JSON = 'json',
  CSV = 'csv',
  PDF = 'pdf'
}

export interface ExportResult {
  url: string;
  filename: string;
  size: number;
  expiresAt: Timestamp;
}

export interface ImportOptions {
  format: ImportFormat;
  overwrite: boolean;
  validateOnly: boolean;
}

export enum ImportFormat {
  JSON = 'json',
  CSV = 'csv'
}

export interface ImportResult {
  success: boolean;
  itemsProcessed: number;
  itemsSuccess: number;
  itemsError: number;
  errors: ImportError[];
}

export interface ImportError {
  row?: number;
  field?: string;
  message: string;
  severity: 'error' | 'warning';
}