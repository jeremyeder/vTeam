package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestCreateProjectSingleNamespaceMode(t *testing.T) {
	// Save original env var and restore after test
	originalMode := os.Getenv("SINGLE_NAMESPACE_MODE")
	defer func() {
		if originalMode == "" {
			os.Unsetenv("SINGLE_NAMESPACE_MODE")
		} else {
			os.Setenv("SINGLE_NAMESPACE_MODE", originalMode)
		}
	}()

	// Set Gin to test mode
	gin.SetMode(gin.TestMode)

	t.Run("returns 501 when SINGLE_NAMESPACE_MODE is true", func(t *testing.T) {
		os.Setenv("SINGLE_NAMESPACE_MODE", "true")

		// Create a test router
		router := gin.New()
		router.POST("/api/projects", CreateProject)

		// Create a test request
		reqBody := `{"name":"test-project","displayName":"Test Project"}`
		req, _ := http.NewRequest("POST", "/api/projects", strings.NewReader(reqBody))
		req.Header.Set("Content-Type", "application/json")

		// Record the response
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		// Verify response
		assert.Equal(t, http.StatusNotImplemented, w.Code, "Should return 501 Not Implemented")

		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err, "Response should be valid JSON")

		assert.Contains(t, response, "error", "Response should contain error field")
		assert.Equal(t, "Project creation disabled in single-namespace mode", response["error"], "Error message should match")

		assert.Contains(t, response, "message", "Response should contain message field")
		assert.Contains(t, response["message"], "This deployment only supports the namespace", "Message should explain single-namespace limitation")

		assert.Contains(t, response, "contact", "Response should contain contact field")
		assert.Contains(t, response["contact"], "Contact platform administrator", "Should provide contact information")
	})

	t.Run("does not return 501 when SINGLE_NAMESPACE_MODE is false", func(t *testing.T) {
		os.Setenv("SINGLE_NAMESPACE_MODE", "false")

		// Create a test router
		router := gin.New()
		router.POST("/api/projects", CreateProject)

		// Create a test request
		reqBody := `{"name":"test-project","displayName":"Test Project"}`
		req, _ := http.NewRequest("POST", "/api/projects", strings.NewReader(reqBody))
		req.Header.Set("Content-Type", "application/json")

		// Record the response
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		// Should not return 501 (will likely return 500 or other error due to missing k8s client in test,
		// but importantly NOT 501)
		assert.NotEqual(t, http.StatusNotImplemented, w.Code, "Should not return 501 when single-namespace mode is disabled")
	})

	t.Run("does not return 501 when SINGLE_NAMESPACE_MODE is not set", func(t *testing.T) {
		os.Unsetenv("SINGLE_NAMESPACE_MODE")

		// Create a test router
		router := gin.New()
		router.POST("/api/projects", CreateProject)

		// Create a test request
		reqBody := `{"name":"test-project","displayName":"Test Project"}`
		req, _ := http.NewRequest("POST", "/api/projects", strings.NewReader(reqBody))
		req.Header.Set("Content-Type", "application/json")

		// Record the response
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		// Should not return 501 when env var is not set (default to multi-namespace mode)
		assert.NotEqual(t, http.StatusNotImplemented, w.Code, "Should not return 501 when SINGLE_NAMESPACE_MODE is not set")
	})
}

func TestCreateProjectErrorMessageFormat(t *testing.T) {
	// Save original env var and restore after test
	originalMode := os.Getenv("SINGLE_NAMESPACE_MODE")
	defer func() {
		if originalMode == "" {
			os.Unsetenv("SINGLE_NAMESPACE_MODE")
		} else {
			os.Setenv("SINGLE_NAMESPACE_MODE", originalMode)
		}
	}()

	// Set Gin to test mode
	gin.SetMode(gin.TestMode)

	t.Run("error response has correct format", func(t *testing.T) {
		os.Setenv("SINGLE_NAMESPACE_MODE", "true")

		// Create a test router
		router := gin.New()
		router.POST("/api/projects", CreateProject)

		// Create a test request
		reqBody := `{"name":"test-project","displayName":"Test Project"}`
		req, _ := http.NewRequest("POST", "/api/projects", strings.NewReader(reqBody))
		req.Header.Set("Content-Type", "application/json")

		// Record the response
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		var response map[string]interface{}
		err := json.Unmarshal(w.Body.Bytes(), &response)
		assert.NoError(t, err, "Response should be valid JSON")

		// Verify all expected fields are present
		expectedFields := []string{"error", "message", "contact"}
		for _, field := range expectedFields {
			assert.Contains(t, response, field, "Response should contain %s field", field)
			assert.NotEmpty(t, response[field], "Field %s should not be empty", field)
		}

		// Verify field types
		assert.IsType(t, "", response["error"], "error field should be a string")
		assert.IsType(t, "", response["message"], "message field should be a string")
		assert.IsType(t, "", response["contact"], "contact field should be a string")
	})
}
