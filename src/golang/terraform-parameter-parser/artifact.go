// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

package main

// Artifact represents the location of a Provisioning Artifact
type Artifact struct {
	Path string `json:"path"`
	Type string `json:"type"`
}
