COMMENT
iterator for traversing all the daughters of the currently accessed section

section subtree_traverse("statement")

executes statement for every daughter of section.
Just before the statement is executed the currently accessed section is set.

ENDCOMMENT

NEURON {
        SUFFIX nothing
}

VERBATIM
static subtree(sec, sym) Section* sec; Symbol* sym; {
        Section* child;

 

        for (child = sec->child; child; child = child->sibling) {
       nrn_pushsec(child);       /* move these three (sec becomes child) */
        hoc_run_stmt(sym);      /* into the loop to do only the first level */
        nrn_popsec(); 

        }
}
ENDVERBATIM

PROCEDURE subtree_traverse() {
  VERBATIM
  {
        Section* chk_access();
        Symbol* hoc_parse_stmt();
        Symlist* symlist = (Symlist*)0;
        subtree(chk_access(), hoc_parse_stmt(gargstr(1), &symlist));
        /* if following not executed (ie hoc error in statement),
           some memory will leak */
        hoc_free_list(&symlist);
  }
  ENDVERBATIM
}
