# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for divitional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License") you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# pylint: disable=invalid-name, unused-argument
#
# This file is part of DNN compiler maintained at
# https://github.com/ai-techsystems/dnnCompiler

import common

import dnnc as dc
import numpy as np
import unittest

def temp_gemm(np_a, np_b, np_c, alpha, beta, transA, transB):
    np_a = np_a.T if (transA==1) else np_a
    np_b = np_b.T if (transB==1) else np_b
    y = (alpha * np.dot(np_a, np_b)) + (beta * np_c)
    return y

class GemmTest(unittest.TestCase):
    def setUp(self):
        self.len_a_b = 12
        self.len_c = 9
        self.alpha = 0.5
        self.beta = 0.5
        self.np_a = np.random.randn(self.len_a_b).astype(np.float32)
        self.np_b = np.random.randn(self.len_a_b).astype(np.float32)
        self.np_c = np.random.randn(self.len_c).astype(np.float32)
        self.dc_a = dc.array(list(self.np_a))
        self.dc_b = dc.array(list(self.np_b))
        self.dc_c = dc.array(list(self.np_c))
    '''
    def test_Gemm1D (self):
        npr = temp_gemm(self.np_a, self.np_b)
        dcr = dc.gemm(self.dc_a, self.dc_b)
        np.testing.assert_allclose(npr, np.array(dcr.data()).astype(np.float32),
                rtol=1e-3, atol=1e-3)
    '''
    def test_Gemm2D (self):
        transA = 0
        transB = 0
        np_a = np.reshape(self.np_a, (3,4))
        np_b = np.reshape(self.np_b, (4,3))
        np_c = np.reshape(self.np_c, (3,3))
        dc_a = dc.reshape(self.dc_a, (3,4))
        dc_b = dc.reshape(self.dc_b, (4,3))
        dc_c = dc.reshape(self.dc_c, (3,3))
        npr = temp_gemm(np_a, np_b, np_c, self.alpha, self.beta, transA, transB)
        dcr = dc.gemm(dc_a, dc_b, dc_c, self.alpha, self.beta, transA, transB)
        np.testing.assert_allclose(npr.flatten(), np.array(dcr.data()).astype(np.float32),
                rtol=1e-3, atol=1e-3)
    '''
    def test_Gemm3D (self):
        np_a = np.reshape(self.np_a, (2,4,3))
        np_b = np.reshape(self.np_b, (2,4,3))
        dc_a = dc.reshape(self.dc_a, (2,4,3))
        dc_b = dc.reshape(self.dc_b, (2,4,3))

        npr = temp_gemm(np_a, np_b)
        dcr = dc.gemm(dc_a, dc_b)

        np.testing.assert_allclose(npr.flatten(), np.array(dcr.data()).astype(np.float32),
                rtol=1e-3, atol=1e-3)

    def test_Gemm4D (self):
        np_a = np.reshape(self.np_a, (2,2,2,3))
        np_b = np.reshape(self.np_b, (2,2,2,3))
        dc_a = dc.reshape(self.dc_a, (2,2,2,3))
        dc_b = dc.reshape(self.dc_b, (2,2,2,3))

        npr = temp_gemm(np_a, np_b)
        dcr = dc.gemm(dc_a, dc_b)

        np.testing.assert_allclose(npr.flatten(), np.array(dcr.data()).astype(np.float32),
                rtol=1e-3, atol=1e-3)
    '''
    def tearDown(self):
        return "test finished"

if __name__ == '__main__':
    unittest.main()
