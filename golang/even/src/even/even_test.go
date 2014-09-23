package even_test

import (
	"even"
	"testing"
)

func TestEven(t *testing.T) {
	if true != even.Even(2) {
		t.Log("2 should be even!")
		t.Fail()
	}
}
