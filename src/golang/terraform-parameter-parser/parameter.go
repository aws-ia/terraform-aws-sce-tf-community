// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

package main

// Parameter represents a single parsed variable from a Provisioning Artifact
type Parameter struct {
	Key string `json:"key"`
	DefaultValue string `json:"defaultValue"`
	Type string `json:"type"`
	Description string `json:"description"`
	IsNoEcho bool `json:"isNoEcho"`
}
