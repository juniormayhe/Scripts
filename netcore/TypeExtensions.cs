namespace Company.Extensions
{
    using System;

    public static class TypeExtensions
    {
        public static bool IsClassOrStruct(this object obj)
        {
            if (obj == null)
            {
                return false;
            }

            Type type = obj.GetType();

            return type.IsClass || IsStruct(type);
        }

        private static bool IsStruct(Type type)
        {
            return type.IsValueType && !type.IsPrimitive;
        }
    }
}
