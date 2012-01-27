/*___INFO__MARK_BEGIN__*/
/*************************************************************************
 * 
 *  The Contents of this file are made available subject to the terms of
 *  the Sun Industry Standards Source License Version 1.2
 * 
 *  Sun Microsystems Inc., March, 2001
 * 
 * 
 *  Sun Industry Standards Source License Version 1.2
 *  =================================================
 *  The contents of this file are subject to the Sun Industry Standards
 *  Source License Version 1.2 (the "License"); You may not use this file
 *  except in compliance with the License. You may obtain a copy of the
 *  License at http://gridengine.sunsource.net/Gridengine_SISSL_license.html
 * 
 *  Software provided under this License is provided on an "AS IS" basis,
 *  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
 *  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
 *  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
 *  See the License for the specific provisions governing your rights and
 *  obligations concerning the Software.
 * 
 *   The Initial Developer of the Original Code is: Sun Microsystems, Inc.
 * 
 *   Copyright: 2001 by Sun Microsystems, Inc.
 * 
 *   All Rights Reserved.
 * 
 ************************************************************************/
/*___INFO__MARK_END__*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#if defined(__STDC__) || defined(__cplusplus)
#define __PR__(x) x
#else
#define __PR__(x) ()
#endif

#define uid_t_fmt "%ld"

static void usage __PR__((FILE *out));

int main __PR__(( int argc, char *argv[]));

/* 
 * start mpich2 mpd daemon and return after forking
 * 
 * this must be done for each selected node for the job
 *
 */

static void usage(out)
FILE *out;
{
   fprintf(out, "usage: start_mpich2 [-n <hostname>] mpich2-mpd-path [mpd-parameters ..]\n");
   fprintf(out, "\n");
   fprintf(out, "where: 'hostname' gives the name of the target host\n");
}

/*-------------------------------------------------------------------------*/
int main(argc, argv)
int argc;
char *argv[];
{
   char*   nodename=NULL;

   char*   rsh_argv[8];

   int optch;
   static char optstring[] = "n:";

   opterr = 0;
   while ((optch=getopt(argc,argv,optstring))!=-1)
      switch (optch)
      {
         case 'n': nodename=malloc(strlen(optarg)+1);
                   strcpy(nodename, optarg);
                   break;

         default: puts("Unknown option!");
      }

   if ((!nodename) ||
       (argc-optind != 3 && argc-optind != 1))
   {
      usage(stderr);
      return 1;
   }

   if (fork())
      exit(0);

   else
   {
      rsh_argv[0]="rsh";
      rsh_argv[1]=nodename;
      rsh_argv[2]=argv[optind];
      if (argc-optind == 1)
          rsh_argv[3]=NULL;
      else
      {
          rsh_argv[3]="-h";
          rsh_argv[4]=argv[optind+1];
          rsh_argv[5]="-p";
          rsh_argv[6]=argv[optind+2];
          rsh_argv[7]="-n";
          rsh_argv[8]=NULL;
      }

      execvp(rsh_argv[0], &rsh_argv[0]);

      fprintf(stderr, "exec %s failed\n", rsh_argv[0]);
   }

   exit(1);
}
