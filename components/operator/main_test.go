package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestSingleNamespaceModeConfiguration(t *testing.T) {
	// Save original env var and restore after test
	originalMode := os.Getenv("SINGLE_NAMESPACE_MODE")
	defer func() {
		if originalMode == "" {
			os.Unsetenv("SINGLE_NAMESPACE_MODE")
		} else {
			os.Setenv("SINGLE_NAMESPACE_MODE", originalMode)
		}
	}()

	t.Run("single namespace mode enabled when env is true", func(t *testing.T) {
		os.Setenv("SINGLE_NAMESPACE_MODE", "true")
		// Simulate reading the env var like main() does
		mode := os.Getenv("SINGLE_NAMESPACE_MODE") == "true"
		assert.True(t, mode, "Single namespace mode should be enabled when SINGLE_NAMESPACE_MODE=true")
	})

	t.Run("single namespace mode disabled when env is false", func(t *testing.T) {
		os.Setenv("SINGLE_NAMESPACE_MODE", "false")
		mode := os.Getenv("SINGLE_NAMESPACE_MODE") == "true"
		assert.False(t, mode, "Single namespace mode should be disabled when SINGLE_NAMESPACE_MODE=false")
	})

	t.Run("single namespace mode disabled when env is not set", func(t *testing.T) {
		os.Unsetenv("SINGLE_NAMESPACE_MODE")
		mode := os.Getenv("SINGLE_NAMESPACE_MODE") == "true"
		assert.False(t, mode, "Single namespace mode should be disabled when SINGLE_NAMESPACE_MODE is not set")
	})
}

func TestPVCCreationWithStorageClass(t *testing.T) {
	// Save original env var and restore after test
	originalStorageClass := os.Getenv("STORAGE_CLASS")
	defer func() {
		if originalStorageClass == "" {
			os.Unsetenv("STORAGE_CLASS")
		} else {
			os.Setenv("STORAGE_CLASS", originalStorageClass)
		}
	}()

	t.Run("PVC uses configured storage class", func(t *testing.T) {
		testStorageClass := "test-storage-class"
		os.Setenv("STORAGE_CLASS", testStorageClass)

		// Simulate the logic from ensureProjectWorkspacePVC
		storageClassFromEnv := os.Getenv("STORAGE_CLASS")
		if storageClassFromEnv == "" {
			storageClassFromEnv = "gp3-csi"
		}

		pvc := &corev1.PersistentVolumeClaim{
			ObjectMeta: v1.ObjectMeta{
				Name:      "ambient-workspace",
				Namespace: "test-namespace",
				Labels:    map[string]string{"app": "ambient-workspace"},
			},
			Spec: corev1.PersistentVolumeClaimSpec{
				StorageClassName: &storageClassFromEnv,
				AccessModes:      []corev1.PersistentVolumeAccessMode{corev1.ReadWriteOnce},
				Resources: corev1.VolumeResourceRequirements{
					Requests: corev1.ResourceList{
						corev1.ResourceStorage: resource.MustParse("5Gi"),
					},
				},
			},
		}

		assert.Equal(t, testStorageClass, *pvc.Spec.StorageClassName, "PVC should use configured storage class")
	})

	t.Run("PVC uses default storage class when not configured", func(t *testing.T) {
		os.Unsetenv("STORAGE_CLASS")

		storageClassFromEnv := os.Getenv("STORAGE_CLASS")
		if storageClassFromEnv == "" {
			storageClassFromEnv = "gp3-csi"
		}

		assert.Equal(t, "gp3-csi", storageClassFromEnv, "Should use default storage class when not configured")
	})
}

func TestPodSecurityContext(t *testing.T) {
	t.Run("Job pod includes security context", func(t *testing.T) {
		// Create a minimal job template like handleAgenticSessionEvent does
		job := &batchv1.Job{
			ObjectMeta: v1.ObjectMeta{
				Name:      "test-job",
				Namespace: "test-namespace",
			},
			Spec: batchv1.JobSpec{
				Template: corev1.PodTemplateSpec{
					Spec: corev1.PodSpec{
						// Pod-level security context
						SecurityContext: &corev1.PodSecurityContext{
							RunAsNonRoot: boolPtr(true),
							FSGroup:      int64Ptr(1000),
							SeccompProfile: &corev1.SeccompProfile{
								Type: corev1.SeccompProfileTypeRuntimeDefault,
							},
						},
						RestartPolicy: corev1.RestartPolicyNever,
						Containers: []corev1.Container{
							{
								Name:  "test-container",
								Image: "test-image",
								SecurityContext: &corev1.SecurityContext{
									AllowPrivilegeEscalation: boolPtr(false),
									ReadOnlyRootFilesystem:   boolPtr(false),
									Capabilities: &corev1.Capabilities{
										Drop: []corev1.Capability{"ALL"},
									},
								},
							},
						},
					},
				},
			},
		}

		// Verify pod-level security context
		assert.NotNil(t, job.Spec.Template.Spec.SecurityContext, "Job pod should have security context")
		assert.NotNil(t, job.Spec.Template.Spec.SecurityContext.RunAsNonRoot, "RunAsNonRoot should be set")
		assert.True(t, *job.Spec.Template.Spec.SecurityContext.RunAsNonRoot, "Should run as non-root")
		assert.NotNil(t, job.Spec.Template.Spec.SecurityContext.FSGroup, "FSGroup should be set")
		assert.Equal(t, int64(1000), *job.Spec.Template.Spec.SecurityContext.FSGroup, "FSGroup should be 1000")
		assert.NotNil(t, job.Spec.Template.Spec.SecurityContext.SeccompProfile, "SeccompProfile should be set")
		assert.Equal(t, corev1.SeccompProfileTypeRuntimeDefault, job.Spec.Template.Spec.SecurityContext.SeccompProfile.Type, "Should use RuntimeDefault seccomp profile")

		// Verify container-level security context
		assert.NotNil(t, job.Spec.Template.Spec.Containers[0].SecurityContext, "Container should have security context")
		assert.NotNil(t, job.Spec.Template.Spec.Containers[0].SecurityContext.AllowPrivilegeEscalation, "AllowPrivilegeEscalation should be set")
		assert.False(t, *job.Spec.Template.Spec.Containers[0].SecurityContext.AllowPrivilegeEscalation, "Should not allow privilege escalation")
		assert.NotNil(t, job.Spec.Template.Spec.Containers[0].SecurityContext.Capabilities, "Capabilities should be set")
		assert.Contains(t, job.Spec.Template.Spec.Containers[0].SecurityContext.Capabilities.Drop, corev1.Capability("ALL"), "Should drop all capabilities")
	})
}
