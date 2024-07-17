# configure

configure_file(
	${CMAKE_CURRENT_SOURCE_DIR}/Makefile.common.in
	${CMAKE_CURRENT_BINARY_DIR}/Makefile.common
	@ONLY
)

install(
	FILES ${CMAKE_CURRENT_BINARY_DIR}/Makefile.common
	DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/
)

