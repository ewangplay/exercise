package even_test

import (
	"even"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("Even", func() {
	Describe("Determine number is even or odd", func() {
		Context("5", func() {
			It("should be an odd", func() {
				Expect(even.Odd(5)).To(Equal(true))
			})
		})

		Context("10", func() {
			It("should be a even", func() {
				Expect(even.Even(10)).To(Equal(true))
			})
		})
	})
})
