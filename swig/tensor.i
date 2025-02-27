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
// tensor.i
//

%ignore *::operator=;
%ignore *::operator[];
%include "python/pyopers.swg"
%include "core/tensor.h"
%include "dnnc_swig_externs.h"
%{
#include <object.h> // where Py_LT, Pt_GT are defined.
#include "core/tensor.h"
#include "operators/Add.h"
#include "operators/Sub.h"
#include "operators/Equal.h"
#include "operators/Less.h"
#include "operators/Greater.h"
#include "dnnc_swig_externs.h"
extern std::vector<size_t> listTupleToVector_SizeT(PyObject *);
%}

%feature("python:slot",    "mp_subscript", functype="binaryfunc")             dnnc::tensor::__getitem__;
%feature("python:slot",    "mp_ass_subscript", functype="objobjargproc")      dnnc::tensor::__setitem__;
//%feature("python:slot",  "sq_slice", functype="ssizessizeargfunc")          __getslice__;
//%feature("python:slot",  "sq_ass_slice", functype="ssizessizeobjargproc")   __setslice__;
%feature("python:slot",    "sq_length", functype="lenfunc")                   dnnc::tensor::length;
%feature("python:slot",    "nb_bool", functype="inquiry")                     dnnc::tensor::operator bool;
%feature("python:slot",    "tp_repr", functype="reprfunc")                    dnnc::tensor::__str__;
%feature("python:slot",    "tp_str", functype="reprfunc")                     dnnc::tensor::__repr__;

%extend dnnc::tensor {
  const T& __getitem__(PyObject* indices) {
    std::vector<size_t> vIndices = listTupleToVector_SizeT(indices);
    const T& item = $self->operator()(vIndices);
    return item;
  }
  void __setitem__(PyObject* indices, const T& data) {
    std::vector<size_t> vIndices = listTupleToVector_SizeT(indices);
    $self->load(data, vIndices);
    return ;
  }
  bool __bool__() const {
    return (self->length());
  }
  std::string __str__() {
    return $self->to_string();
  }
  std::string __repr__() {
    return $self->to_string();
  }
  /* unary operators */
  %pybinoperator(__neg__, dnnc::tensor::__neg__, unaryfunc, nb_negative);
  dnnc::tensor<T> __neg__() const {
    return $self->negate();
  }
  %pybinoperator(__abs__, dnnc::tensor::__abs__, unaryfunc, nb_absolute);
  dnnc::tensor<T> __abs__() const {
    return $self->absolute();
  }
  /* binary operators */
  %pybinoperator(__add__, dnnc::tensor::__add__, binaryfunc, nb_add);
  dnnc::tensor<T> __add__(dnnc::tensor<T>& other) {
    dnnc::Add<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  dnnc::tensor<T> __add__(T scalar) {
    dnnc::tensor<T> other(1);
    other.load(&scalar);

    dnnc::Add<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  // 'swig -builtin' option limits all reverse operator from being overloaded.
  //       y=1+x; #(whre x and y are tensors) will not work
  %pybinoperator(__radd__, dnnc::tensor::__radd__, binaryfunc, nb_radd);
  dnnc::tensor<T> __radd__(T scalar) {
    dnnc::tensor<T> other(1);
    other.load(&scalar);

    dnnc::Add<T> op("pythonOp");
    return op.compute(*$self, other);
  }

  %pybinoperator(__sub__, dnnc::tensor::__sub__, binaryfunc, nb_subtract);
  dnnc::tensor<T> __sub__(dnnc::tensor<T>& other) {
    dnnc::Sub<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  dnnc::tensor<T> __sub__(T scalar) {
    dnnc::tensor<T> other(1);
    other.load(&scalar);

    dnnc::Sub<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  // 'swig -builtin' option limits all reverse operator from being overloaded.
  //       y=1-x; #(whre x and y are tensors) will not work
  %pybinoperator(__rsub__, dnnc::tensor::__rsub__, binaryfunc, nb_rsubtract);
  dnnc::tensor<T> __rsub__(T scalar) {
    dnnc::tensor<T> other(1);
    other.load(&scalar);

    dnnc::Sub<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  /* assignment operators */
  %pyinplaceoper(__iadd__, dnnc::tensor::__iadd__, binaryfunc, nb_inplace_add);
  dnnc::tensor<T> __iadd__(dnnc::tensor<T>& other) {
    dnnc::Add<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  dnnc::tensor<T> __iadd__(T scalar) {
    dnnc::tensor<T> other(1);
    other.load(&scalar);

    dnnc::Add<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  %pyinplaceoper(__isub__, dnnc::tensor::__isub__, binaryfunc, nb_inplace_subtract);
  dnnc::tensor<T> __isub__(dnnc::tensor<T>& other) {
    dnnc::Sub<T> op("pythonOp");
    return op.compute(*$self, other);
  }
  /* comparision operators */
  %pycompare(__lt__, dnnc::tensor::__lt__, Py_LT);
  dnnc::tensor<bool> __lt__(dnnc::tensor<T>& other) {
    dnnc::Less<T> op;
    return op.compute(*$self, other);
  }
  %pycompare(__gt__, dnnc::tensor::__gt__, Py_GT);
  dnnc::tensor<bool> __gt__(dnnc::tensor<T>& other) {
    dnnc::Greater<T> op;
    return op.compute(*$self, other);
  }
  %pycompare(__eq__, dnnc::tensor::__eq__, Py_EQ);
  dnnc::tensor<bool> __eq__(dnnc::tensor<T>& other) {
    dnnc::Equal<T> op;
    return op.compute(*$self, other);
  }
}
%template(bTensor) dnnc::tensor<bool>;
%template(iTensor) dnnc::tensor<int>;
%template(fTensor) dnnc::tensor<float>;
%template(dTensor) dnnc::tensor<double>;
namespace std {
  %template(itvec) vector<dnnc::tensor<int> >;
  %template(ftvec) vector<dnnc::tensor<float> >;
}

