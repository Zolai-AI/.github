/**
 * Stage 1 draft contract for Zolai core auth capabilities.
 * Source of truth: GET /api/v1/auth/capabilities (zolai-core, additive, public-safe).
 * Server is authoritative; UI gating is UX only.
 */

export const CAPABILITIES_CONTRACT_VERSION = "1.0.0-draft" as const;

export type CoreRole = "anonymous" | "member" | "admin" | "superadmin";

export type CanonicalRoleV1 = CoreRole;

export type AuthSource = "anonymous" | "api_key" | "session" | "oauth";

export type AuthMode = "off" | "warn" | "enforce" | string;

export interface AuthCapabilities {
  can_read_public: boolean;
  can_chat_assistant: boolean;
  can_run_agent: boolean;
  can_read_agent: boolean;
  can_manage_users: boolean;
  can_manage_api_keys: boolean;
  can_manage_settings: boolean;
  can_manage_roles: boolean;
  can_view_audit: boolean;
  [key: string]: boolean;
}

export interface AuthFeatureFlags {
  public_assistant: boolean;
  public_contributions: boolean;
  session_auth_enabled: boolean;
  [key: string]: boolean;
}

export interface AuthCapabilitiesResponse {
  role: CoreRole;
  canonical_role: CanonicalRoleV1;
  scopes: string[];
  capabilities: AuthCapabilities;
  feature_flags: AuthFeatureFlags;
  auth_source: AuthSource;
  mode: AuthMode;
  contract_version: typeof CAPABILITIES_CONTRACT_VERSION | string;
}

/**
 * Draft mapping for web Better Auth roles to canonical v1 roles.
 * Runtime enforcement remains in zolai-core for core-backed operations.
 */
export const WEB_BETTER_AUTH_ROLE_TO_CANONICAL_V1 = {
  USER: "member",
  VIEWER: "member",
  CONTRIBUTOR: "member",
  AUTHOR: "member",
  EDITOR: "member",
  MODERATOR: "admin",
  CONTENT_ADMIN: "admin",
  ADMIN: "admin",
  SUPER_ADMIN: "superadmin",
} as const;

export type WebBetterAuthRole = keyof typeof WEB_BETTER_AUTH_ROLE_TO_CANONICAL_V1;