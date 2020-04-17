cmake_minimum_required(VERSION 3.1)

include(CMakeParseArguments)

# generate sources for messages via opp_msgc
macro(generate_opp_message)
    cmake_parse_arguments(GEN_OPP_MSG "LEGACY" "" "MESSAGE_FILES" ${ARGN})
    if(NOT DEFINED GEN_OPP_MSG_MESSAGE_FILES)
        message(SEND_ERROR "generate_opp_message called without MESSAGE_FILES! "
                           "Valid options are: <MESSAGE_FILES items> [LEGACY]")
    endif()

    if(GEN_OPP_MSG_LEGACY)
        set(_msg_version_arg "--msg4")
    endif()

    foreach(_msg_input IN ITEMS ${GEN_OPP_MSG_MESSAGE_FILES})
        if(NOT IS_ABSOLUTE ${_msg_input})
            set(_msg_output_source "${CMAKE_CURRENT_SRC_DIR}/${_msg_input}")
        endif()

        get_filename_component(_msg_name "${_msg_input}" NAME_WE)
        get_filename_component(_msg_dir "${_msg_input}" DIRECTORY)

        # Path of sources and headers to be generated, respectively
        set(_msg_output_source "${_msg_dir}/${_msg_name}_m.cc")
        set(_msg_output_header "${_msg_dir}/${_msg_name}_m.h")

        add_custom_command(OUTPUT "${_msg_output_source}" "${_msg_output_header}"
            COMMAND ${OMNETPP_MSGC}
            ARGS ${_msg_version_arg} -s _m.cc ${_msg_input}
            DEPENDS ${_msg_input} ${OMNETPP_MSGC}
            COMMENT "Generating ${_msg_dir}/${_msg_name}_m.(cc|h)"
            VERBATIM)
    endforeach()
endmacro()

macro(clean_opp_messages)
    execute_process(COMMAND "${OMNETPP_MSGC}" ERROR_VARIABLE _output OUTPUT_VARIABLE _output)
    string(REGEX MATCH "Version: [0-9\.]+[a-z0-9]+, build: [^ ,]+" _opp_msgc_identifier "${_output}")
    if (NOT "${_opp_msgc_identifier}" STREQUAL "${OMNETPP_MSGC_IDENTIFIER}")
        file(REMOVE_RECURSE ${PROJECT_BINARY_DIR}/opp_messages)
    endif()
    set(OMNETPP_MSGC_IDENTIFIER ${_opp_msgc_identifier} CACHE INTERNAL "identification of OMNeT++ message compiler" FORCE)
endmacro()
variable_watch(OMNETPP_MSGC clean_opp_messages)
