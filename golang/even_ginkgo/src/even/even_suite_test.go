package even_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"testing"
)

func TestEven(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Even Suite")
}
