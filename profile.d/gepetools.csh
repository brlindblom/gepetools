# Copyright 2012, Brian Smith
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

# Define some vars if TMPDIR is set (inside a job)
if ( -n "${TMPDIR}" ) then
    setenv MPICH_HOSTS ${TMPDIR}/machines.mpich
    setenv MVAPICH_HOSTS ${TMPDIR}/machines.mvapich
    setenv MVAPICH2_HOSTS ${TMPDIR}/machines.mvapich2
    setenv MPICH2_HOSTS ${TMPDIR}/machines.mpich2
    setenv HPMPI_HOSTS ${TMPDIR}/machines.hpmpi
    setenv INTELMPI_HOSTS ${TMPDIR}/machines.intelmpi
    setenv LAM_HOSTS ${TMPDIR}/machines.lam
    setenv ANSYS_HOSTS `cat ${TMPDIR}/machines.ansys`
    setenv LINDA_HOSTS `cat ${TMPDIR}/machines.linda`
end
