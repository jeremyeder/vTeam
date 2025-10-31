/**
 * WebSocket hook for real-time session updates
 * Connects to backend WebSocket hub and updates React Query cache
 */

import { useEffect, useRef } from "react";
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

  // Store callbacks in refs to avoid recreating connect function
  const callbacksRef = useRef({ onConnect, onDisconnect, onError });

  useEffect(() => {
    callbacksRef.current = { onConnect, onDisconnect, onError };
  }, [onConnect, onDisconnect, onError]);

  useEffect(() => {
    // Reset reconnection counter on mount
    reconnectAttemptsRef.current = 0;

    // Don't connect if disabled
    if (!enabled || !projectName || !sessionName) return;

    const connect = () => {
      // Don't connect if already connecting
      if (wsRef.current?.readyState === WebSocket.CONNECTING) return;

      // Close existing connection if any
      if (wsRef.current) {
        wsRef.current.close();
      }

      // Determine WebSocket URL
      // In browser, use relative path with protocol upgrade
      const protocol =
        window.location.protocol === "https:" ? "wss:" : "ws:";
      const host = window.location.host;
      const wsUrl = `${protocol}//${host}/api/projects/${projectName}/sessions/${sessionName}/ws`;

      console.log(`[WebSocket] Connecting to session ${sessionName}...`);
      const ws = new WebSocket(wsUrl);
      wsRef.current = ws;

      ws.onopen = () => {
        console.log(`[WebSocket] Connected to session ${sessionName}`);
        reconnectAttemptsRef.current = 0; // Reset reconnect counter
        callbacksRef.current.onConnect?.();
      };

      ws.onmessage = (event) => {
        try {
          const message: WebSocketMessage = JSON.parse(event.data);

          // Ignore ping/pong messages
          if (message.type === "ping" || message.type === "pong") {
            return;
          }

          // Validate message belongs to this session
          if (message.sessionId !== sessionName) {
            console.warn(
              `[WebSocket] Received message for wrong session: ${message.sessionId}, expected: ${sessionName}`
            );
            return;
          }

          console.log(`[WebSocket] Message received:`, message.type);

          // Update messages cache by appending new message
          queryClient.setQueryData<SessionMessage[]>(
            sessionKeys.messages(projectName, sessionName),
            (oldMessages = []) => {
              // Check for duplicate based on timestamp + type + partial
              const isDuplicate = oldMessages.some(
                (existing) =>
                  existing.timestamp === message.timestamp &&
                  existing.type === message.type &&
                  JSON.stringify(existing.partial) ===
                    JSON.stringify(message.partial)
              );

              if (isDuplicate) {
                console.debug("[WebSocket] Ignoring duplicate message");
                return oldMessages;
              }

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
        callbacksRef.current.onError?.(event);
      };

      ws.onclose = () => {
        console.log(`[WebSocket] Disconnected from session ${sessionName}`);
        callbacksRef.current.onDisconnect?.();
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
    };

    connect();

    // Cleanup on unmount
    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
        reconnectTimeoutRef.current = null;
      }
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
    };
  }, [enabled, projectName, sessionName, queryClient]);

  return {
    isConnected: wsRef.current?.readyState === WebSocket.OPEN,
  };
}
