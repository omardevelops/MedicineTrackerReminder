"""HalalFinds - ingredient-label halal classification.

    >>> from halalfinds import classify
    >>> classify("Sugar, gelatine", country="GB").ruling
    <Ruling.MASHBOOH: 'mashbooh'>
"""

from .classify import classify
from .models import Entry, Finding, Ruling, Verdict
from .render import render

__version__ = "0.1.0"
__all__ = ["classify", "render", "Ruling", "Verdict", "Finding", "Entry"]
