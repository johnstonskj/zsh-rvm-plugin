# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: rvm
# @brief: Setup for the `rvm` package manager.
# @repository: https://github.com/johnstonskj/zsh-rvm-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# Public variables:
#
# * `RVM`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_OLD_HOME`; the previous value of the `RVM_HOME` environment variable.
# * `RVM_HOME`; the home directory for RVM.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA RVM
RVM[_PLUGIN_DIR]="${0:h}"
RVM[_ALIASES]=""
RVM[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
RVM[_OLD_HOME]="${RVM_HOME}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `RVM[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.rvm_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${RVM[_FUNCTIONS]}" ]]; then
        RVM[_FUNCTIONS]="${fn_name}"
    elif [[ ",${RVM[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        RVM[_FUNCTIONS]="${RVM[_FUNCTIONS]},${fn_name}"
    fi
}
.rvm_remember_fn .rvm_remember_fn

.rvm_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${RVM[_ALIASES]}" ]]; then
        RVM[_ALIASES]="${alias_name}"
    elif [[ ",${RVM[_ALIASES]}," != *",${alias_name},"* ]]; then
        RVM[_ALIASES]="${RVM[_ALIASES]},${alias_name}"
    fi
}
.rvm_remember_fn .rvm_remember_alias

#
# This function does the initialization of variables in the global variable
# `RVM`. It also adds to `path` and `fpath` as necessary.
#
rvm_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    # Export environment variables.
    export RVM_HOME="${RVM_HOME:-${HOME}/.rvm}"

    # Add _PATH to path.
    path+=( "${RVM_HOME}/bin" )
}
.rvm_remember_fn rvm_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
rvm_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${RVM[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${RVM[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Removing _PATH entries.
    path=( "${(@)path:#${RVM_HOME}/bin}" )
    
    # Reset global environment variables .
    export RVM_HOME="${RVM[_OLD_HOME]}"

    # Remove the global data variable.
    unset RVM

    # Remove this function.
    unfunction rvm_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

rvm_plugin_init

true
