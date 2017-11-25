/*
 * Copyright (C) 2017 Katarina Sheremet
 * This file is part of Delern.
 *
 * Delern is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Delern is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with  Delern.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.dasfoo.delern.util;

/**
 * {@link java.util.function.Consumer}.
 *
 * @param <T> {@link java.util.function.Consumer}
 */
public interface Consumer<T> {
    /**
     * {@link java.util.function.Consumer#accept(Object)}.
     *
     * @param data {@link java.util.function.Consumer#accept(Object)}
     */
    void accept(T data);
}
