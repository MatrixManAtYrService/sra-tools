# ===========================================================================
#
#                            PUBLIC DOMAIN NOTICE
#               National Center for Biotechnology Information
#
#  This software/database is a "United States Government Work" under the
#  terms of the United States Copyright Act.  It was written as part of
#  the author's official duties as a United States Government employee and
#  thus cannot be copyrighted.  This software/database is freely available
#  to the public for use. The National Library of Medicine and the U.S.
#  Government have not placed any restriction on its use or reproduction.
#
#  Although all reasonable efforts have been taken to ensure the accuracy
#  and reliability of the software and data, the NLM and the U.S.
#  Government do not and cannot warrant the performance or results that
#  may be obtained by using this software or data. The NLM and the U.S.
#  Government disclaim all warranties, express or implied, including
#  warranties of performance, merchantability or fitness for any particular
#  purpose.
#
#  Please cite the author in any work or product based on this material.
#
# ==============================================================================$

add_compile_definitions( __mod__="test/external/sra-stat" )

if ( NOT WIN32 )
    ToolsRequired(sra-stat)

	#add_executable( testAssemblyStatistics testAssemblyStatistics )
	GenerateExecutableWithDefs( testAssemblyStatistics "testAssemblyStatistics" "" "" "${COMMON_LINK_LIBRARIES};${COMMON_LIBS_READ}" )
	#target_link_libraries( testAssemblyStatistics ${COMMON_LINK_LIBRARIES} ${COMMON_LIBS_READ} )

	add_test( NAME Test_Sra_stat_dflt
		COMMAND test-sra-stat.sh ${DIRTOTEST} sra-stat
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	if( RUN_SANITIZER_TESTS )
		add_test( NAME Test_Sra_stat-asan
			COMMAND test-sra-stat.sh ${DIRTOTEST} sra-stat-asan
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
		add_test( NAME Test_Sra_stat-tsan
			COMMAND test-sra-stat.sh ${DIRTOTEST} sra-stat-tsan
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	endif()

	if ( EXISTS "${DIRTOTEST}/bam-load${EXE}" )
	    # specify the location of schema files in a local .kfg file, to be used by the tests here as needed
	    add_test(NAME LatfLoadTestSetup COMMAND
	        bash -c "echo 'vdb/schema/paths = \"${VDB_INCDIR}\"\n' > tmp.kfg"
	        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	    set_tests_properties(
	        LatfLoadTestSetup PROPERTIES FIXTURES_SETUP LatfLoadTest )

	    add_test( NAME Test_Sra_stat_unln
		    COMMAND
		        ${CMAKE_COMMAND} -E env NCBI_SETTINGS=/
		        ${CMAKE_COMMAND} -E env VDB_CONFIG=${CMAKE_CURRENT_SOURCE_DIR}
		        ./test-sra-stat-unaligned-bam.sh ${DIRTOTEST} sra-stat
		    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	    set_tests_properties(
	        Test_Sra_stat_unln PROPERTIES FIXTURES_REQUIRED LatfLoadTest )
	endif()

	add_test( NAME SlowTest_Sra_stat
		COMMAND test-sra-stat-slow.sh ${DIRTOTEST} sra-stat
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	if( RUN_SANITIZER_TESTS )
		add_test( NAME SlowTest_Sra_stat-asan
			COMMAND test-sra-stat-slow.sh ${DIRTOTEST} sra-stat-asan
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
		add_test( NAME SlowTest_Sra_stat-tsan
			COMMAND test-sra-stat-slow.sh ${DIRTOTEST} sra-stat-tsan
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	endif()

endif()
