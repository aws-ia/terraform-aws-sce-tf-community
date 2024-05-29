# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import setuptools

setuptools.setup(
    packages=setuptools.find_packages(),
    package_data={"sce_terraform_community": ["schemas/*.json"]},
)
