# For more technical details, see:
#
#    * Metzler, D. and Croft, W.B., "A Markov Random Field Model for Term Dependencies," ACM SIGIR 2005.
#
#    * Metzler, D., Strohman T., Turtle H., and Croft, W.B., "Indri at TREC 2004: Terabyte Track", TREC 2004.
#
#    * http://ciir.cs.umass.edu/~metzler/
#
# NOTES
#
#    * this script assumes that the query string has already been parsed and that all characters
#      that are not compatible with Indri's query language have been removed.
#
#    * it is not advisable to do a 'full dependence' variant on long strings because of the exponential
#      number of terms that will result. it is suggested that the 'sequential dependence' variant be
#      used for long strings. either that, or split up long strings into smaller cohesive chunks and
#      apply the 'full dependence' variant to each of the chunks.
#
#    * the unordered features use a window size of 4 * number of terms within the phrase. this has been
#      found to work well across a wide range of collections and topics. however, this may need to be
#      modified on an individual basis.
#

#
# formulates a query based on query text and feature weights
#
# arguments:
#    * query - string containing original query terms separated by spaces
#    * type  - string. "sd" for sequential dependence or "fd" for full dependence variant. defaults to "fd".
#    * wt[0] - weight assigned to term features
#    * wt[1] - weight assigned to ordered (#1) features
#    * wt[2] - weight assigned to unordered (#uw) features
#
import bitstring
import re


def formulate_query(query, dependence_type='sd', field='', wt1=0.5, wt2=0.25, wt3=0.25):
    """
    >>> formulate_query("white house rose garden", "sd", '', 0.5, 0.25, 0.25)
    '#weight( 0.5 #combine( white house rose garden  ) 0.25 #combine( #1( rose garden ) #1( house rose ) #1( white house ) )  0.25 #combine( #uw8( rose garden ) #uw8( house rose ) #uw8( white house ) ) ) '

    >>> formulate_query("white house rose garden", "fd", '', 0.8, 0.1, 0.1)
    '#weight( 0.8 #combine( white house rose garden  ) 0.1 #combine( #1( rose garden ) #1( house rose ) #1( house rose garden ) #1( white house ) #1( white house rose ) #1( white house rose garden ) )  0.1 #combine( #uw8( rose garden ) #uw8( house garden ) #uw8( house rose ) #uw12( house rose garden ) #uw8( white garden ) #uw8( white rose ) #uw12( white rose garden ) #uw8( white house ) #uw12( white house garden ) #uw12( white house rose ) #uw16( white house rose garden ) ) ) '
    """

    if field is not '':
        field = "." + field
    # trim whitespace from beginning and end of query string
    query = query.strip()
    phrase_match = re.compile('^0+11+[^1]*$')

    queryT = "#combine( "
    queryO = "#combine( "
    queryU = "#combine( "

    # generate term features (f_T)
    terms = query.split()

    for term in terms:
        queryT += term + field + ' '
    num_terms = len(terms)

    # skip the rest of the processing if we're just
    # interested in term features or if we only have 1 term
    if (wt2 == 0.0 and wt3 == 0.0) or num_terms == 1:
        return queryT + ")"

    # generate the rest of the features
    if dependence_type is "sd":
        start = 3
    else:
        start = 1

    i = start
    while i < (2 ** num_terms):
        bin_val = bitstring.pack("uint:32", i).read('bin:32')  # create binary representation of i
        num_extracted = 0
        extracted_terms = ""

        # get query terms corresponding to 'on' bits
        for j in range(0, num_terms):
            bit = bin_val[(j - num_terms):][0]
            if bit is "1":
                extracted_terms += terms[j]  + " "
                num_extracted += 1

        # skip these, since we already took care of the term features...
        if num_extracted == 1:
            i += 1
            continue

        # words in contiguous phrase, ordered features (f_O)
        if phrase_match.match(bin_val):  # =~ / ^ 0+11+[^ 1] * $ / ):
            queryO += "#1( " + str(extracted_terms) + ")" + field + " "

        # every subset of terms, unordered features (f_U)
        queryU += "#uw" + str(4 * num_extracted) + "( " + extracted_terms + ")" + field + " "
        if dependence_type is "sd":
            i *= 2
        else:
            i += 1

    final_query = "#weight("
    if wt1 != 0.0 and queryT is not "#combine( ":
        final_query += " " + str(wt1) + " " + queryT + " )"
    if wt2 != 0.0 and queryO is not "#combine(":
        final_query += " " + str(wt2) + " " + queryO + ") "
    if wt3 != 0.0 and queryU is not "#combine(":
        final_query += " " + str(wt2) + " " + queryU + ") "

    if final_query is "#weight(":
        return ""  # return "" if we couldn't formulate anything

    return final_query + ") "
