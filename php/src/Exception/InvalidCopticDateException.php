<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk\Exception;

use InvalidArgumentException;

final class InvalidCopticDateException extends InvalidArgumentException
{
    public function __construct(public readonly int $year, public readonly int $month, public readonly int $day)
    {
        parent::__construct("Invalid Coptic date: $year-$month-$day");
    }
}
