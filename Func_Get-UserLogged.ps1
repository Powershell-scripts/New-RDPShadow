function Get-UserLogged {
    <#
    .SYNOPSIS
    Получает ID пользователя для создания удаленного подключения  
    
    .DESCRIPTION
    Получаем данные удаленного пользователя через утилиту quser. 
    Мы получаем данные по списку
             
    ComputerName
    UserName
    DateLogged
    UserID
    
    .PARAMETER -PCName
    Принимает только Имя ПК например ilc-pvl-cash1 или *pvl-cash* - если не в курсе что за комп, но есть понимание как он должен называться
    * - это флаг любого символа          
    
    .EXAMPLE
     Get-UserLogged -PCName *pvl-cash* 
     Вернет данные кассы с павелецкой 
    
    .NOTES
    Взято отсюда и переделанно под себя
    https://fixmypc.ru/post/poluchenie-spiska-zaloginennykh-polzovatelei-ad-i-ikh-kompiuterov-v-powershell/
    
    #>
        # Эта часть принимает имена компьютеров через конвейер (значение по умолчанию localhost)
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeline=$True)]
            [string]$PCName
        )
        $ErrorMessage = "Не должно быть больше двух ПК в списке. Посмотри и вбей нужный." + "`n`r" + "Список ниже: "
        $PCNames = Get-ADComputer -Filter "name -like '$PCName'"
        if ($PCNames.name.count -gt 1) {
            $ComputerNames = $PCNames.Name
            $ErrorMessage + "`n`r" + "$ComputerNames"
            break
            }
    
        else {
            $ComputerName = $PCNames.Name
            }
    
        $query = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            quser
            }
                        
        # Проверка ошибок с доступностью портов, протоколов
        if ($query -like "*Error*"){
            $UserName = ""
            # Ошибка будет отображаться в этом поле, в одну строку
            $DateLogged = $query -replace '\n',' '
            }
                        
        elseif ($query -ne $Null ){
            # Убираем первую строку из вывода,
            # заменяем два пробела запятыми
            $query = ($query -split '\n')[1] -replace '\s{2,}',','
            # Преобразуем в массив
            $result = $query -split ','
            # разделяем массив на объекты
            $UserName = $result[0].substring(1);
            $DateLogged = $result[-1];
            $UserID = $result[2];
            }
                        
        else {
            $UserName = ""
            # Если ответ $querry равен Null, 
            # то будет выводиться следующее сообщение
            $DateLogged = "Компьютер выключен или пользователь не вошел в систему"   
            }
                        
        # На некоторых компьютерах появляется надпись "Отсутствует"
        # способ ниже уберет ее, если появится
        $DateLogged = $DateLogged -replace 'отсутствует ',''
        # Добавляем все объекты в массив типа PSCustomObject
        $user_logged = [PSCustomObject]@{
            ComputerName = $ComputerName;
            UserName = $UserName;
            DateLogged = $DateLogged;
            UserID = $UserID;
            }
    
        return $user_logged    
        }
    