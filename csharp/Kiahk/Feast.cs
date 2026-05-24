using System.Collections.Generic;

namespace Kiahk;

/// <summary>
/// A calendar-resolved feast: a <see cref="FeastRecord"/>'s metadata paired with the
/// Gregorian date on which it falls for a particular year.
/// </summary>
public sealed record Feast(
    string Id,
    string Type,
    string Category,
    IReadOnlyDictionary<string, string> Names,
    GregorianDate GregorianDate)
{
    /// <summary>
    /// Return the feast's localized name for <paramref name="locale"/>.
    /// Supported locales: "en", "ar". Unknown locales throw <see cref="UnsupportedLocaleException"/>.
    /// </summary>
    public string Name(string locale)
    {
        if (Names.TryGetValue(locale, out var n))
        {
            return n;
        }
        throw new UnsupportedLocaleException(Id, locale);
    }
}
