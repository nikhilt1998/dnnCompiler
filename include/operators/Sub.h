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
template <typename T> class Sub : public baseOperator<T> {
  template <typename Scalar>
  inline DNNC_EIGEN_VECTOR_CTOR(Scalar)
      eigenArraySub(Map<DNNC_EIGEN_VECTOR_CTOR(Scalar)> &a,
                    Map<DNNC_EIGEN_VECTOR_CTOR(Scalar)> &b) {
    return a.array() - b.array();
  }
  // Eigen does not support subtraction operator for bool
  // So specialiazation is needed to work around that limitation.
  // Bug Ref: http://eigen.tuxfamily.org/bz/show_bug.cgi?id=426
  inline DNNC_EIGEN_VECTOR_CTOR(bool)
      eigenArraySub(Map<DNNC_EIGEN_VECTOR_CTOR(bool)> &a,
                    Map<DNNC_EIGEN_VECTOR_CTOR(bool)> &b) {
    auto eigenVectorIA = a.template cast<uint8_t>();
    auto eigenVectorIB = b.template cast<uint8_t>();
    DNNC_EIGEN_VECTOR_CTOR(uint8_t) eIResult;
    eIResult.array() = eigenVectorIA.array() - eigenVectorIB.array();
    return eIResult.template cast<bool>();
  }

public:
  Sub(std::string name = "opSub") : baseOperator<T>(opSub, name) {}

  // bool getAttribute<int>(OPATTR attrName, int& obj) ;

  tensor<T> compute(tensor<T> a /*!< : N D tensor input*/,
                    tensor<T> b /*!< : N D tensor input*/) {

    std::vector<DIMENSION> resultShape = binaryBroadcastReShape(a, b);
    tensor<T> result(resultShape);

    if (a.shape() != b.shape())
      throw std::invalid_argument(
          "tensor dimenions not appropriate for Sub operator.");
    // Written for arbitrary Dimension.

    DNNC_EIGEN_ARRAY_MAP(eigenVectorA, a);
    DNNC_EIGEN_ARRAY_MAP(eigenVectorB, b);

    DNNC_EIGEN_VECTOR_CTOR(T)
    eResult = eigenArraySub(eigenVectorA, eigenVectorB);

    result.load(eResult.data());

    return result;
  }
  /*!<
  \return The output tensor of the same shape and type as input.
  */
};
} // namespace dnnc
