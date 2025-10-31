// Core types for RFE Workflows and GitHub integration

export type Project = {
  name: string;
  displayName: string;
  description?: string;
  labels: Record<string, string>;
  annotations: Record<string, string>;
  creationTimestamp: string;
  status: string;
};

export type Workspace = {
  id: string;
  workspaceSlug: string;
  upstreamRepoUrl: string;
  canonicalBranch: string;
  specifyFeatureSlug: string;
  s3Bucket: string;
  s3Prefix: string;
  createdByUserId: string;
  createdAt: string;
  project: string;
};

export type Session = {
  id: string;
  workspaceId: string;
  userId: string;
  inputRepoUrl: string;
  inputBranch: string;
  outputRepoUrl: string;
  outputBranch: string;
  status: 'queued' | 'running' | 'succeeded' | 'failed';
  flags: string[];
  prLinks: PRLink[];
  runnerType: 'claude' | 'openai' | 'localexec';
  startedAt: string;
  finishedAt?: string;
  project: string;
};

export type PRLink = {
  repoUrl: string;
  branch: string;
  targetBranch: string;
  url: string;
  status: 'open' | 'merged' | 'closed';
};

export type GitHubFork = {
  name: string;
  fullName: string;
  url: string;
  owner: {
    login: string;
    avatar_url: string;
  };
  private: boolean;
  default_branch: string;
};

export type RepoTree = {
  path?: string;
  entries: RepoEntry[];
};

export type RepoEntry = {
  name: string;
  type: 'blob' | 'tree';
  size?: number;
  sha?: string;
};

export type RepoBlob = {
  content: string;
  encoding: string;
  size: number;
};

export type GitHubInstallation = {
  installationId: number;
  githubUserId: string;
  login: string;
  avatarUrl?: string;
};

export type SessionMessage = {
  seq: number;
  type: string;
  timestamp: string;
  payload: Record<string, unknown>;
  partial?: {
    id: string;
    index: number;
    total: number;
    data: string;
  };
};

export type UserAccess = {
  user: string;
  project: string;
  access: 'view' | 'edit' | 'admin' | 'none';
  allowed: boolean;
};

export type APIError = {
  error: string;
  code?: string;
  details?: Record<string, unknown>;
};