from numpy import euler_gamma
from scipy.special import digamma

def harmonic_number(s):
    """ If s is complex the result becomes complex. """
    return digamma(s + 1) + euler_gamma