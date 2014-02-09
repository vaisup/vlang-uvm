//
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   Copyright 2014 Coverify Systems Technology
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

module uvm.tlm1.uvm_tlm_fifo_base;
import uvm.tlm1.uvm_imps;
import uvm.tlm1.uvm_analysis_port;

import uvm.base.uvm_component;
import uvm.base.uvm_object_globals;
import uvm.base.uvm_phase;

import esdl.base.core;

class uvm_tlm_event
{
  Event trigger;
  this() {
    synchronized(this) {
      trigger.init("trigger");
    }
  }
}

//------------------------------------------------------------------------------
//
// CLASS: uvm_tlm_fifo_base #(T)
//
// This class is the base for <uvm_tlm_fifo #(T)>. It defines the TLM exports
// through which all transaction-based FIFO operations occur. It also defines
// default implementations for each inteface method provided by these exports.
//
// The interface methods provided by the <put_export> and the <get_peek_export>
// are defined and described by <uvm_tlm_if_base #(T1,T2)>.  See the TLM Overview
// section for a general discussion of TLM interface definition and usage.
//
// Parameter type
//
// T - The type of transactions to be stored by this FIFO.
//
//------------------------------------------------------------------------------

abstract class uvm_tlm_fifo_base(T=int): uvm_component
{
  enum string UVM_TLM_FIFO_TASK_ERROR =
    "fifo channel task not implemented";
  enum string UVM_TLM_FIFO_FUNCTION_ERROR =
    "fifo channel function not implemented";

  alias uvm_tlm_fifo_base!(T) this_type;

  // Port: put_export
  //
  // The ~put_export~ provides both the blocking and non-blocking put interface
  // methods to any attached port:
  //
  //|  task put (input T t)
  //|  function bit can_put ()
  //|  function bit try_put (input T t)
  //
  // Any ~put~ port variant can connect and send transactions to the FIFO via this
  // export, provided the transaction types match. See <uvm_tlm_if_base #(T1,T2)>
  // for more information on each of the above interface methods.

  uvm_put_imp!(T, this_type) put_export;


  // Port: get_peek_export
  //
  // The ~get_peek_export~ provides all the blocking and non-blocking get and peek
  // interface methods:
  //
  //|  task get (output T t)
  //|  function bit can_get ()
  //|  function bit try_get (output T t)
  //|  task peek (output T t)
  //|  function bit can_peek ()
  //|  function bit try_peek (output T t)
  //
  // Any ~get~ or ~peek~ port variant can connect to and retrieve transactions from
  // the FIFO via this export, provided the transaction types match. See
  // <uvm_tlm_if_base #(T1,T2)> for more information on each of the above interface
  // methods.

  uvm_get_peek_imp!(T, this_type) get_peek_export;


  // Port: put_ap
  //
  // Transactions passed via ~put~ or ~try_put~ (via any port connected to the
  // <put_export>) are sent out this port via its ~write~ method.
  //
  //|  function void write (T t)
  //
  // All connected analysis exports and imps will receive put transactions.
  // See <uvm_tlm_if_base #(T1,T2)> for more information on the ~write~ interface
  // method.

  uvm_analysis_port!(T) put_ap;


  // Port: get_ap
  //
  // Transactions passed via ~get~, ~try_get~, ~peek~, or ~try_peek~ (via any
  // port connected to the <get_peek_export>) are sent out this port via its
  // ~write~ method.
  //
  //|  function void write (T t)
  //
  // All connected analysis exports and imps will receive get transactions.
  // See <uvm_tlm_if_base #(T1,T2)> for more information on the ~write~ method.

  uvm_analysis_port!(T) get_ap;


  // The following are aliases to the above put_export.

  uvm_put_imp      !(T, this_type) blocking_put_export;
  uvm_put_imp      !(T, this_type) nonblocking_put_export;

  // The following are all aliased to the above get_peek_export, which provides
  // the superset of these interfaces.

  uvm_get_peek_imp !(T, this_type) blocking_get_export;
  uvm_get_peek_imp !(T, this_type) nonblocking_get_export;
  uvm_get_peek_imp !(T, this_type) get_export;

  uvm_get_peek_imp !(T, this_type) blocking_peek_export;
  uvm_get_peek_imp !(T, this_type) nonblocking_peek_export;
  uvm_get_peek_imp !(T, this_type) peek_export;

  uvm_get_peek_imp !(T, this_type) blocking_get_peek_export;
  uvm_get_peek_imp !(T, this_type) nonblocking_get_peek_export;


  // Function: new
  //
  // The ~name~ and ~parent~ are the normal uvm_component constructor arguments.
  // The ~parent~ should be null if the uvm_tlm_fifo is going to be used in a
  // statically elaborated construct (e.g., a module). The ~size~ indicates the
  // maximum size of the FIFO. A value of zero indicates no upper bound.

  public this(string name = null, uvm_component parent = null) {
    synchronized(this) {
      super(name, parent);

      put_export = new uvm_put_imp!(T, this_type) ("put_export", this);
      blocking_put_export     = put_export;
      nonblocking_put_export  = put_export;

      get_peek_export = new uvm_get_peek_imp!(T, this_type)("get_peek_export",
							    this);
      blocking_get_peek_export    = get_peek_export;
      nonblocking_get_peek_export = get_peek_export;
      blocking_get_export         = get_peek_export;
      nonblocking_get_export      = get_peek_export;
      get_export                  = get_peek_export;
      blocking_peek_export        = get_peek_export;
      nonblocking_peek_export     = get_peek_export;
      peek_export                 = get_peek_export;

      put_ap = new uvm_analysis_port!(T)("put_ap", this);
      get_ap = new uvm_analysis_port!(T)("get_ap", this);

    }
  }

  //turn off auto config
  override public void build_phase(uvm_phase phase) {
    build(); //for backward compat, won't cause auto-config
    // return;
  }

  override public void flush() {
    uvm_report_error("flush", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
  }

  public size_t size() {
    uvm_report_error("size", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  // task
  public void put(T t) {
    uvm_report_error("put", UVM_TLM_FIFO_TASK_ERROR, UVM_NONE);
  }

  // task
  public void get(out T t) {
    uvm_report_error("get", UVM_TLM_FIFO_TASK_ERROR, UVM_NONE);
  }

  // task
  public void peek(out T t) {
    uvm_report_error("peek", UVM_TLM_FIFO_TASK_ERROR, UVM_NONE);
  }

  public bool try_put(T t) {
    uvm_report_error("try_put", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public bool try_get(out T t) {
    uvm_report_error("try_get", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public bool try_peek(out T t) {
    uvm_report_error("try_peek", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public bool can_put() {
    uvm_report_error("can_put", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public bool can_get() {
    uvm_report_error("can_get", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public bool can_peek() {
    uvm_report_error("can_peek", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public uvm_tlm_event ok_to_put() {
    uvm_report_error("ok_to_put", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return null;
  }

  public uvm_tlm_event ok_to_get() {
    uvm_report_error("ok_to_get", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return null;
  }

  public uvm_tlm_event ok_to_peek() {
    uvm_report_error("ok_to_peek", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return null;
  }

  public bool is_empty() {
    uvm_report_error("is_empty", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

  public bool is_full() {
    uvm_report_error("is_full", UVM_TLM_FIFO_FUNCTION_ERROR);
    return 0;
  }

  public size_t used() {
    uvm_report_error("used", UVM_TLM_FIFO_FUNCTION_ERROR, UVM_NONE);
    return 0;
  }

}
