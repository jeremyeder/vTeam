/**
 * WebSocket hook for real-time session updates
 * Connects to backend WebSocket hub and updates React Query cache
 */

import { useEffect, useRef, useCallback } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { sessionKeys } from "@/services/queries/use-sessions";

type WebSocketMessage = {
  sessionId: string;
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

type SessionMessage = {
  sessionId: string;
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

type UseSessionWebSocketOptions = {
  enabled?: boolean;
  onConnect?: () => void;
  onDisconnect?: () => void;
  onError?: (error: Event) => void;
};

export function useSessionWebSocket(
  projectName: string,
  sessionName: string,
  options: UseSessionWebSocketOptions = {}
) {
  const { enabled = true, onConnect, onDisconnect, onError } = options;
  const queryClient = useQueryClient();
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const reconnectAttemptsRef = useRef(0);
  const maxReconnectAttempts = 5;
  const baseReconnectDelay = 1000; // 1 second

  const connect = useCallback(() => {
    // Don't connect if disabled or already connecting
    if (!enabled || !projectName || !sessionName) return;
    if (wsRef.current?.readyState === WebSocket.CONNECTING) return;

    // Close existing connection if any
    if (wsRef.current) {
      wsRef.current.close();
    }

    // Determine WebSocket URL
    // In browser, use relative path with protocol upgrade
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    const host = window.location.host;
    const wsUrl = `${protocol}//${host}/api/projects/${projectName}/sessions/${sessionName}/ws`;

    console.log(`[WebSocket] Connecting to session ${sessionName}...`);
    const ws = new WebSocket(wsUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      console.log(`[WebSocket] Connected to session ${sessionName}`);
      reconnectAttemptsRef.current = 0; // Reset reconnect counter
      onConnect?.();
    };

    ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data);

        // Ignore ping/pong messages
        if (message.type === "ping" || message.type === "pong") {
          return;
        }

        console.log(`[WebSocket] Message received:`, message.type);

        // Update messages cache by appending new message
        queryClient.setQueryData<SessionMessage[]>(
          sessionKeys.messages(projectName, sessionName),
          (oldMessages = []) => {
            // Convert WebSocket message to SessionMessage format
            const newMessage: SessionMessage = {
              sessionId: message.sessionId,
              type: message.type,
              timestamp: message.timestamp,
              payload: message.payload,
              partial: message.partial,
            };
            return [...oldMessages, newMessage];
          }
        );

        // If status-related message, invalidate session details to refetch
        const statusTypes = [
          "agent.running",
          "agent.waiting",
          "result.message",
          "system.message",
        ];
        if (statusTypes.includes(message.type)) {
          queryClient.invalidateQueries({
            queryKey: sessionKeys.detail(projectName, sessionName),
          });
        }
      } catch (error) {
        console.error("[WebSocket] Failed to parse message:", error);
      }
    };

    ws.onerror = (event) => {
      console.error(`[WebSocket] Error:`, event);
      onError?.(event);
    };

    ws.onclose = () => {
      console.log(`[WebSocket] Disconnected from session ${sessionName}`);
      onDisconnect?.();
      wsRef.current = null;

      // Attempt reconnection with exponential backoff
      if (enabled && reconnectAttemptsRef.current < maxReconnectAttempts) {
        const delay =
          baseReconnectDelay * Math.pow(2, reconnectAttemptsRef.current);
        console.log(
          `[WebSocket] Reconnecting in ${delay}ms (attempt ${reconnectAttemptsRef.current + 1}/${maxReconnectAttempts})`
        );

        reconnectTimeoutRef.current = setTimeout(() => {
          reconnectAttemptsRef.current++;
          connect();
        }, delay);
      } else if (reconnectAttemptsRef.current >= maxReconnectAttempts) {
        console.error(
          "[WebSocket] Max reconnection attempts reached. Giving up."
        );
      }
    };
  }, [
    projectName,
    sessionName,
    enabled,
    queryClient,
    onConnect,
    onDisconnect,
    onError,
  ]);

  useEffect(() => {
    connect();

    // Cleanup on unmount
    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
    };
  }, [connect]);

  return {
    isConnected: wsRef.current?.readyState === WebSocket.OPEN,
    reconnect: connect,
  };
}
