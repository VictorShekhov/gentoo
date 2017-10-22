# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

VERSION="Oracle JDK @PV@"
JAVA_HOME="@GENTOO_PORTAGE_EPREFIX@/opt/@P@"
JDK_HOME="@GENTOO_PORTAGE_EPREFIX@/opt/@P@"
JAVAC=${JAVA_HOME}/bin/javac
PATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin"
ROOTPATH="${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin"
LDPATH="${JAVA_HOME}/jre/lib/@PLATFORM@/:${JAVA_HOME}/jre/lib/@PLATFORM@/xawt/:${JAVA_HOME}/jre/lib/@PLATFORM@/server/"
MANPATH="@GENTOO_PORTAGE_EPREFIX@/opt/@P@/man"
PROVIDES_TYPE="JDK JRE"
PROVIDES_VERSION="1.9"
BOOTCLASSPATH="${JAVA_HOME}/lib/resources.jar:${JAVA_HOME}/jre/lib/sunrsasign.jar:${JAVA_HOME}/jre/lib/jsse.jar:${JAVA_HOME}/lib/jce.jar:${JAVA_HOME}/lib/charsets.jar:${JAVA_HOME}/classes"
GENERATION="2"
ENV_VARS="JAVA_HOME JDK_HOME JAVAC PATH ROOTPATH LDPATH MANPATH"
