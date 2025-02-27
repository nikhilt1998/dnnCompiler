// Copyright 2018 The AITS DNNC Authors.All Rights Reserved.
//
// Licensed to the Apache Software Foundation(ASF) under one
// or more contributor license agreements.See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.See the License for the
// specific language governing permissionsand limitations
// under the License.
//
// This file is part of AITS DNN compiler maintained at
// https://github.com/ai-techsystems/dnnCompiler
//

#pragma once
#include "operators/baseOperator.h"
#include <string>

using namespace Eigen;

namespace dnnc {
template <typename T> class Xor : public baseOperator<T> {
  
public:
  Xor(std::string name = "opXor") : baseOperator<T>(opXor, name) {}

  /*! Element wise Xor-Function*/
  static T xor_function(T x, T y) {
    return (!x != !y) ? true : false;
  }
  
  tensor<T> compute(tensor<T> a, tensor<T> b) {

    if (!(this->template type_check<bool>()))
      throw std::invalid_argument(
        "Constrain input and output types to float tensors.");

    std::vector<DIMENSION> resultShape = binaryBroadcastReShape(a, b);
    tensor<T> result(resultShape);

    if (a.shape() != b.shape())
      throw std::invalid_argument(
          "tensor dimenions not appropriate for Xor operator.");

    // for (size_t i = 0; i < a.length(); i++)
    //   result[i] = (!a[i] != !b[i]) ? true : false;

    DNNC_EIGEN_ARRAY_MAP(eigenVectorA, a);
    DNNC_EIGEN_ARRAY_MAP(eigenVectorB, b);
    DNNC_EIGEN_VECTOR_CTOR(T) eResult;
    eResult.array() = eigenVectorA.array().binaryExpr(eigenVectorB.array(), &xor_function);
    result.load(eResult.data());

    return result;
  }
};
} // namespace dnnc
