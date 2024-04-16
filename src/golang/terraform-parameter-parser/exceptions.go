// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

package main

type ParserInvalidParameterException struct {
	Message string
}

type ParserAccessDeniedException struct {
	Message string
}

func (e ParserInvalidParameterException) Error() string {
	return e.Message
}

func (e ParserAccessDeniedException) Error() string {
	return e.Message
}
