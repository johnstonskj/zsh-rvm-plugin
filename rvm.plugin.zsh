# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: rvm
# @brief: Setup for the `rvm` package manager.
# @repository: https://github.com/johnstonskj/zsh-rvm-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# ### Public Variables
#
# * `RVM_HOME`; the home directory for RVM.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

rvm_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save rvm RVM_HOME
    export RVM_HOME="${RVM_HOME:-${HOME}/.rvm}"

    @zplugins_add_to_path rvm "${RVM_HOME}/bin"
}

# @internal
rvm_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore rvm RVM_HOME
}
