package main

import (
	"fmt"
	"github.com/ewangplay/bi_search_tree"
)

func main() {
	bst := &bstree.BiSearchTree{}
	bst.Add(10)
	bst.Add(25)
	bst.Add(15)
	bst.Add(33)
	bst.Add(24)
	bst.Add(19)
	bst.Add(3)
	bst.Add(9)
	bst.Add(40)
	bst.Add(32)

	travelFun := func(v int64) {
		fmt.Println(v)
	}

	bst.InOrderTravel(travelFun)
	fmt.Println()

	bst.Delete(19)

	bst.InOrderTravel(travelFun)
	fmt.Println()

	rootNode := bst.GetRoot()
	if rootNode != nil {
		fmt.Println("root node: ", rootNode)
	}

	snode := bst.Search(33)
	if snode != nil {
		fmt.Println("searched node: ", snode)
	}

	fmt.Println("Tree Deepth: ", bst.GetDeepth())

	fmt.Println("Min node data: ", bst.GetMin())
	fmt.Println("Max node data: ", bst.GetMax())

	preNode := bst.GetPredecessor(15)
	if preNode != nil {
		fmt.Println("The predecessor node: ", preNode)
	}

	nextNode := bst.GetSuccessor(15)
	if nextNode != nil {
		fmt.Println("The successor node: ", nextNode)
	}

}
